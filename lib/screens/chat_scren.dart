import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

class ImageChat extends StatefulWidget {
  const ImageChat({super.key});

  @override
  State<ImageChat> createState() => _ImageChatState();
}

class _ImageChatState extends State<ImageChat> {
  final Gemini gemini = Gemini.instance;
  List<types.Message> messages = [];
  final types.User myUser = types.User(id: '0', firstName: 'Me');
  final types.User geminiUser = types.User(id: '1', firstName: 'CorpCognizer');
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  String _voiceText = '';
  TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        _extractText(filePath);
      }
    }
  }

  Future<List<int>> _readDocumentData(String name) async {
    final File file = File(name);
    return await file.readAsBytes();
  }

  Future<void> _extractText(String path) async {
    PdfDocument document =
        PdfDocument(inputBytes: await _readDocumentData(path));
    PdfTextExtractor extractor = PdfTextExtractor(document);
    String text = extractor.extractText();
    pdfText(text);
  }

  Future<void> _startListening() async {
    bool available = await _speechToText.initialize();

    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (val) {
        setState(() {
          _voiceText = val.recognizedWords;
          _textController.text = _voiceText;
        });
      });
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CorpCognizer"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Chat(
        messages: messages,
        onSendPressed: sendMessage,
        user: myUser,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: sendImage,
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: pickFile,
          ),
          IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            onPressed: () {
              if (_isListening) {
                _stopListening();
                if (_voiceText.isNotEmpty) {
                  sendMessage(types.PartialText(text: _voiceText));
                }
              } else {
                _startListening();
              }
            },
          ),
        ],
      ),
    );
  }

  void sendMessage(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: myUser,
      id: const Uuid().v4(),
      text: message.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    setState(() => messages.insert(0, textMessage));
  }

  void sendImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      File imageFile = File(file.path);
      final imageMessage = types.ImageMessage(
        author: myUser,
        id: const Uuid().v4(),
        size: imageFile.lengthSync(),
        name: 'Image',
        uri: file.path,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      setState(() => messages.insert(0, imageMessage));
    }
  }

  void pdfText(String data) {
    if (data.isNotEmpty) {
      sendMessage(types.PartialText(text: data));
    }
  }
}
