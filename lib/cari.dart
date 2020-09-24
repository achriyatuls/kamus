import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void main() => runApp(SearchBar());

class SearchBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchBar();
  }
}

class _SearchBar extends State<SearchBar> {
  bool searching, error;
  var data;
  String query;
  String dataurl = "http://192.168.54.8/flutter_kamus/search.php";

  @override
  void initState() {
    searching = false;
    error = false;
    query = "";
    super.initState();
  }

  void getSuggestion() async {
    var res = await http.post(dataurl + "?query=" + Uri.encodeComponent(query));

    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        //update data value and UI
      });
    } else {
      //there is error
      setState(() {
        error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: searching
              ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      searching = false;
                      //set not searching on back button press
                    });
                  },
                )
              : Icon(Icons.play_arrow),
          //if searching is true then show arrow back else play arrow
          title: searching ? searchField() : Text("Paribasan"),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    searching = true;
                  });
                }), // search icon button
          ],
          backgroundColor: searching ? Colors.orange : Colors.deepOrange,
          //ganti warna otomatis saat diketik
        ),
        body: SingleChildScrollView(
            child: Container(
                alignment: Alignment.center,
                child: data == null
                    ? Container(
                        padding: EdgeInsets.all(20),
                        child: searching
                            ? Text("Please wait")
                            : Text("cari berdasar kata"))
                    : Container(
                        child: searching
                            ? showSearchSuggestions()
                            : Text("menemukan kata"),
                      ))));
  }

  Widget showSearchSuggestions() {
    List<SearchSuggestion> suggestionlist =
        List<SearchSuggestion>.from(data["data"].map((i) {
      return SearchSuggestion.fromJSON(i);
    }));

    //serilizing json data inside model list.
    return Column(
      children: suggestionlist.map((suggestion) {
        return InkResponse(
            onTap: () {
              print(suggestion.id);
            },
            child: SizedBox(
                width: double.infinity,
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      suggestion.bahasausing,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )));
      }).toList(),
    );
  }

  Widget searchField() {
    //search input field
    return Container(
        child: TextField(
      autofocus: true,
      style: TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintStyle: TextStyle(color: Colors.white, fontSize: 18),
        hintText: "Mencari Kata",
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ), //under line border, set OutlineInputBorder() for all side border
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ), // focused border color
      ), //decoration for search input field
      onChanged: (value) {
        query = value; //update the value of query
        getSuggestion(); //start to get suggestion
      },
    ));
  }
}

//serarch suggestion data model to serialize JSON data
class SearchSuggestion {
  String id, bahasausing;
  SearchSuggestion({this.id, this.bahasausing});

  factory SearchSuggestion.fromJSON(Map<String, dynamic> json) {
    return SearchSuggestion(
      id: json["id"],
      bahasausing: json["bahasausing"],
    );
  }
}
