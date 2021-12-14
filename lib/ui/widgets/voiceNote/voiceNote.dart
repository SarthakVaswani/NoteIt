import 'package:flutter/material.dart';
import 'package:notes_app/ui/widgets/voiceNote/voice_class.dart';

class VoiceNote extends StatefulWidget {
  const VoiceNote({Key key}) : super(key: key);

  @override
  _VoiceNoteState createState() => _VoiceNoteState();
}

class _VoiceNoteState extends State<VoiceNote> {
  final recorder = NoteRecorder();
  @override
  void initState() {
    // TODO: implement initState
    recorder.init();
    super.initState();
  }

  @override
  void dispose() {
    recorder.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = recorder.isRecording;
    final text = isRecording ? 'STOP' : 'STat';
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: FlatButton(
                  onPressed: () async {
                    final isRecording = await recorder.toggleRec();
                    setState(() {});
                  },
                  child: Text(text)))
        ],
      ),
    );
  }
}
