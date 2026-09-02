import 'package:Wavelet/theme/colors.dart';
import 'package:flutter/material.dart';

class NowPlayingCard extends StatefulWidget {
  NowPlayingCard(
    {
      super.key,
      required this.deviceName,
      required this.songArtist,
      required this.songTitle,
      required this.status,

    }
    );

  @override
  State<NowPlayingCard> createState() => _NowPlayingCardState();

  String deviceName;
  String songArtist;
  String songTitle;
  bool status;
}

class _NowPlayingCardState extends State<NowPlayingCard> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      

      children: [

          //Album cover
          Container(
            decoration: BoxDecoration(
              
            ),
            child: Icon(Icons.music_note),
          )
      ],
    );
  }
}