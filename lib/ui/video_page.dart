import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  @override
  VideoPageState createState() => VideoPageState();
}

class VideoPageState extends State<VideoPage> {
  dynamic controller;
  final TextEditingController urlTextController = TextEditingController();
  final List<String> samplesUrl = [
    "https://media.w3.org/2010/05/sintel/trailer.mp4",
    "https://vt.tumblr.com/tumblr_o600t8hzf51qcbnq0_480.mp4",
    "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
  ];
  var hasSourceUri = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Builder(builder: (context) {
      if (hasSourceUri) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (hasSourceUri) setSourceUri(false);
          },
          child: Stack(
            children: [
              VideoPlayer(controller),
              ControlsOverlay(
                controller: controller,
              )
            ],
          ),
        );
      } else {
        return Column(
          children: [
            SizedBox(
                height: 180,
                child: ListView.builder(
                    itemCount: samplesUrl.length + 1,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text((index == 0)
                            ? "Sample url ->"
                            : samplesUrl[index - 1]),
                        onTap: () {
                          if (index > 0) {
                            setVideoPlayer(samplesUrl[index - 1]);
                          }
                        },
                      );
                    })
                ),
            SizedBox(
              height: 10,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text("Input source url : "),
                  Container(
                    width: 300,
                    color: Colors.black12,
                    child: TextField(
                      controller: urlTextController,
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      var inputText = urlTextController.text;
                      if (inputText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please input video url.')));
                      } else if (!Uri.parse(inputText).isAbsolute) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Url is wrong format. Please check url.')));
                      } else {
                        setVideoPlayer(inputText);
                      }
                    },
                    child: Text('Enter'),
                  )
                ]),
          ],
        );
      }
    }));
  }

  void setVideoPlayer(String url) {
    controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        controller.setLooping(true);
        controller.play();
      });
    setSourceUri(true);
  }

  void setSourceUri(bool value) {
    setState(() {
      hasSourceUri = value;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    urlTextController.dispose();
    super.dispose();
  }
}

class ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}
