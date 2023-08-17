// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';

import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = "";
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search.isEmpty) {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=BoH0H9yDg58bbQou9pK4USn8j4ziwSVj&limit=20&offset=0&rating=g&bundle=messaging_non_clips"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=BoH0H9yDg58bbQou9pK4USn8j4ziwSVj&q=$_search&limit=19&offset=$_offset&rating=g&lang=en&bundle=messaging_non_clips"));
    }

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Image.network(
            "https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif"),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onSubmitted: (text) {
                setState(() {
                  _search = text;
                  _offset = 0;
                });
              },
              decoration: const InputDecoration(
                  labelText: "Pesquise Aqui!",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Container(
                      width: 200,
                      height: 200,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 5.0,
                      ),
                    );

                  default:
                    if (snapshot.hasError) {
                      return Container();
                    } else {
                      return _createGifTable(context, snapshot);
                    }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getCount(List data) {
    if (_search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _getCount(snapshot.data["data"]),
      itemBuilder: (context, index) {
        if (_search.isEmpty || index < snapshot.data["data"].length) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      GifPage(gifData: snapshot.data['data'][index])));
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data["data"][index]["images"]["fixed_height"]
                  ["url"],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onLongPress: () {
              Share.share(snapshot.data["images"]["fixed_height"]["url"]);
            },
          );
        } else {
          return Container(
            child: GestureDetector(
              child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70,
                    ),
                    Text(
                      "Carregar Mais...",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ]),
              onTap: () {
                setState(() {
                  _offset += 19;
                });
              },
            ),
          );
        }
      },
    );
  }
}
