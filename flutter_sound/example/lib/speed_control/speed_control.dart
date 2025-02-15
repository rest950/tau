/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 (LGPL-V3), as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

/*
 *
 * This is a very simple example for Flutter Sound beginners,
 * that show how to record, and then playback a file.
 *
 * This example is really basic.
 *
 */

const _boum = 'assets/samples/sample2.aac';

///
typedef Fn = void Function();

/// Example app.
class SpeedControl extends StatefulWidget {
  @override
  _SpeedControlState createState() => _SpeedControlState();
}

class _SpeedControlState extends State<SpeedControl> {
  final TauPlayer _mPlayer = TauPlayer();
  bool _mPlayerIsInited = false;
  double _mSpeed = 100.0;
  Uint8List? _boumData;

  @override
  void initState() {
    super.initState();
    init().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
  }

  @override
  void dispose() {
    stopPlayer(_mPlayer);

    // Be careful : you must `close` the audio session when you have finished with it.
    _mPlayer.close();

    super.dispose();
  }

  Future<void> init() async {
    await _mPlayer.open();
    await _mPlayer.setSpeed(
        1.0); // This dummy instruction is MANDATORY on iOS, before the first `startRecorder()`.
    _boumData = await getAssetData(_boum);
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  // -------  Here is the code to playback  -----------------------

  void play(TauPlayer? player) async {
    await player!.startPlayer(
        fromDataBuffer: _boumData,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        });
    setState(() {});
  }

  Future<void> stopPlayer(TauPlayer player) async {
    await player.stopPlayer();
  }

  Future<void> setSpeed(double v) async // v is between 0.0 and 100.0
  {
    v = v > 200.0 ? 200.0 : v;
    _mSpeed = v;
    setState(() {});
    await _mPlayer.setSpeed(
      v / 100,
    );
  }

  // --------------------- UI -------------------

  Fn? getPlaybackFn(TauPlayer? player) {
    if (!_mPlayerIsInited) {
      return null;
    }
    return player!.isStopped
        ? () {
            play(player);
          }
        : () {
            stopPlayer(player).then((value) => setState(() {}));
          };
  }

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      //return Column(
      //children: [
      return Container(
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.all(3),
        height: 140,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFFFAF0E6),
          border: Border.all(
            color: Colors.indigo,
            width: 3,
          ),
        ),
        child: Column(children: [
          Row(children: [
            ElevatedButton(
              onPressed: getPlaybackFn(_mPlayer),
              //color: Colors.white,
              //disabledColor: Colors.grey,
              child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
            ),
            SizedBox(
              width: 20,
            ),
            Text(_mPlayer.isPlaying
                ? 'Playback #1 in progress'
                : 'Player #1 is stopped'),
          ]),
          Text('Speed:'),
          Slider(
            value: _mSpeed,
            min: 0.0,
            max: 200.0,
            onChanged: setSpeed,
            //divisions: 100
          ),
        ]),
        //),
        //],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Speed Control'),
      ),
      body: makeBody(),
    );
  }
}
