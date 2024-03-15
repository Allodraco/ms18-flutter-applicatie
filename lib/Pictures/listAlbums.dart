import 'package:flutter/material.dart';
import '../Pictures/models/category.dart';
import '../Api/apiManager.dart';
import '../globals.dart';
import '../config.dart';
import '../menu.dart';

class ListAlbums extends StatefulWidget {
  const ListAlbums({super.key});

  @override
  _ListAlbumsState createState() => _ListAlbumsState();
}

class _ListAlbumsState extends State<ListAlbums> {
  String displayedTitle = 'List Albums';
  List<Category> allCategories = [];
  List<Category> filteredCategories = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    fetchAlbums();
    searchController.addListener(onSearchChanged);
  }

  void onSearchChanged() {
    setState(() {
      filteredCategories = filterCategories();
    });
  }

  List<Category> filterCategories() {
    String query = searchController.text.toLowerCase();
    return allCategories.where((category) => category.name.toLowerCase().contains(query) && (selectedYear == null || category.year == selectedYear)).toList();
  }

  void fetchAlbums() async {
    setState(() => isLoading = true);
    try {
      final response = await ApiManager.get<List<dynamic>>('api/albums', getHeaders());
      final albums = response.map((albumJson) => Category.fromJson(albumJson)).toList();
      setState(() {
        allCategories = albums;
        filteredCategories = filterCategories();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void addCategory() {
    TextEditingController nameController = TextEditingController();
    TextEditingController yearController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(hintText: 'Name')),
            TextField(controller: yearController, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Year (Optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              await postCategory(nameController.text, yearController.text);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> postCategory(String name, String year) async {
    try {
      String formattedName = formatText(name);

      Map<String, dynamic> body = {
        'name': formattedName,
      };

      if (year.isNotEmpty) {
        body['year'] = int.tryParse(year);
      }

      await ApiManager.post('api/albums', body, getHeaders());
      fetchAlbums();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Category added successfully')),
      );
    } catch (e) {
      print('Error adding category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding category: $e')),
      );
    }
  }

  String formatText(String input) {
    if (input.isEmpty) {
      return input;
    }

    List<String> words = input.split(' ');
    words.forEach((word) {
      if (word.isNotEmpty) {
        words[words.indexOf(word)] =
            word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
    });

    return words.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Menu(
      title: Text('Albums', style: TextStyle(color: Colors.white)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(displayedTitle),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child:DropdownButton<int>(
                hint: Text('Filter by Year'),
                value: selectedYear,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                    filteredCategories = filterCategories();
                  });
                },
                items: [null, for (int year = 2000; year <= DateTime.now().year; year++) year].map<DropdownMenuItem<int>>((int? value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value != null ? value.toString() : 'All Years'),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  labelText: 'Search Albums',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: onSearchChanged,
                  ),
                ),
                onSubmitted: (value) => onSearchChanged(),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredCategories.isEmpty
                  ? Center(child: Text("No categories found."))
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = filteredCategories[index];
                  return GestureDetector(
                    onTap: () {
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(category.name),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addCategory,
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

