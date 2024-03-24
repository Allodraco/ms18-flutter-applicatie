import 'package:flutter/material.dart';
import 'package:ms18_applicatie/Pictures/photo_gallery_screen.dart';
import '../Pictures/models/category.dart';
import 'package:ms18_applicatie/Pictures/add_picture_screen.dart';
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
  TextEditingController searchController = TextEditingController();
  List<Category> allCategories = [];
  List<Category> filteredCategories = [];
  bool isLoading = true;
  String? selectedParentAlbumId;
  int? selectedYear;
  List<int> years = [];
  int? selectedSortYear;

  @override
  void initState() {
    super.initState();
    fetchAlbums();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    setState(() {
      filteredCategories = filterCategories();
    });
  }

  List<Category> filterCategories() {
    String query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      return allCategories
          .where((category) => category.parentAlbumId == currentAlbum)
          .toList();
    } else {
      return allCategories.where((category) {
        bool matchesQuery = category.name.toLowerCase().contains(query);
        bool matchesYear =
            selectedSortYear == null || category.year == selectedSortYear;
        return matchesQuery && matchesYear;
      }).toList();
    }
  }

  void fetchAlbums() async {
    setState(() => isLoading = true);
    try {
      final response =
          await ApiManager.get<List<dynamic>>('api/albums', getHeaders());
      final albums =
          response.map((albumJson) => Category.fromJson(albumJson)).toList();

      years =
          albums.map((album) => album.year).whereType<int>().toSet().toList();
      years.sort();

      setState(() {
        allCategories = albums;
        filteredCategories = allCategories
            .where((cat) => cat.parentAlbumId == currentAlbum)
            .toList();
        isLoading = false;
      });
      onSearchChanged(); // Update filtered categories after fetching
    } catch (e) {
      print("Error fetching albums: $e");
      setState(() => isLoading = false);
    }
  }

  String formatTextWithEllipsis(String input, int maxLength) {
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

    String result = words.join(' ');

    if (result.length > maxLength) {
      result = '${result.substring(0, maxLength - 3)}...';
    }

    return result;
  }

  Future<void> showDeleteConfirmationDialog(
      String albumTitle, String albumId, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Bevestig Verwijdering',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      const TextSpan(text: 'Weet je zeker dat je '),
                      TextSpan(
                          text: formatTextWithEllipsis(albumTitle, 20),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(
                          text: ' en alle onderliggende onderdelen wilt '),
                      const TextSpan(
                          text: 'verwijderen',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const TextSpan(text: '?'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ja'),
              onPressed: () {
                deleteAlbum(albumId, index);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Nee'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteAlbum(String albumId, int index) async {
    setState(() => isLoading = true);
    try {
      await ApiManager.delete('api/albums/$albumId', getHeaders());
      setState(() {
        allCategories.removeWhere((category) =>
            category.id == albumId || category.parentAlbumId == albumId);
        filteredCategories.removeWhere((category) =>
            category.id == albumId || category.parentAlbumId == albumId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Album successfully deleted")));
    } catch (e) {
      print("Error deleting album: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting album: $e")));
    } finally {
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
            TextField(
                controller: nameController,
                decoration: InputDecoration(hintText: 'Name')),
            TextField(
                controller: yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Year (Optional)')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel')),
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

  Future<void> postCategory(String name, String year) async {
    try {
      String formattedName = formatText(name);

      Map<String, dynamic> body = {
        'name': formattedName,
      };

      if (year.isNotEmpty) {
        body['year'] = int.tryParse(year);
      }

      if (currentAlbum != null) {
        body['parentAlbumId'] = currentAlbum;
      }

      await ApiManager.post('api/albums', body, getHeaders());
      fetchAlbums(); // Refresh the albums/categories list
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

  void editAlbum(BuildContext context, Category category, int index) {
    TextEditingController nameController =
        TextEditingController(text: category.name);
    TextEditingController yearController =
        TextEditingController(text: category.year?.toString() ?? '');

    String? tempSelectedParentAlbumId = category.parentAlbumId;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Album'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                        controller: nameController,
                        decoration: const InputDecoration(hintText: 'Name')),
                    TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(hintText: 'Year (Optional)')),
                    const Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      // Adjust padding as needed
                      child: Align(
                        alignment: Alignment.centerLeft,
                        // Aligns the text to the left
                        child: Text(
                          "Parent Album:", // Your label text
                          style: TextStyle(
                            fontWeight: FontWeight.bold, // Makes the text bold
                            fontSize: 16.0, // Adjust the font size as needed
                          ),
                        ),
                      ),
                    ),
                    DropdownButton<String>(
                      value: tempSelectedParentAlbumId,
                      isExpanded: true,
                      hint: Text("Select Parent Album"),
                      onChanged: (value) {
                        setStateDialog(() {
                          tempSelectedParentAlbumId = value;
                        });
                      },
                      items: [
                        const DropdownMenuItem<String>(
                          value: null, // This represents the "None" option
                          child: Text("None"),
                        ),
                        ...allCategories
                            .where((c) =>
                                c.id != category.id && (c.photoCount ?? 0) == 0)
                            .map<DropdownMenuItem<String>>((Category category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  selectedParentAlbumId = tempSelectedParentAlbumId;
                });
                await updateCategory(category.id, nameController.text,
                    yearController.text, tempSelectedParentAlbumId);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateCategory(
      String id, String name, String year, String? parentAlbumId) async {
    try {
      Map<String, dynamic> body = {'name': name};
      if (year.isNotEmpty) body['year'] = int.tryParse(year);
      if (parentAlbumId != null) body['parentAlbumId'] = parentAlbumId;

      await ApiManager.put('api/albums/$id', body, getHeaders());

      fetchAlbums();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Album updated successfully')));
    } catch (e) {
      print('Error updating album: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating album: $e')));
    }
  }

  void goBackToParentAlbum() {
    if (currentAlbum == null) {
      return;
    }

    Category? currentCategory;
    try {
      // find the current album in the allCategories list
      currentCategory =
          allCategories.firstWhere((category) => category.id == currentAlbum);
    } catch (e) {
      // If the album is not found, an exception will be caught, and currentCategory will remain null
      currentAlbum = null;
    }

    setState(() {
      // If an album is found, set currentAlbum to its parentAlbumId. Otherwise, set currentAlbum to null.
      currentAlbum = currentCategory?.parentAlbumId;
      fetchAlbums(); // Refresh the list based on the new currentAlbum
    });

    // Update the displayed title after the state is updated
    if (currentAlbum != null) {
      setState(() {
        displayedTitle = allCategories
            .firstWhere((category) => category.id == currentAlbum)
            .name;
      });
    } else {
      setState(() {
        displayedTitle = 'List Albums';
      });
    }
  }

  void onAlbumClicked(Category album) {
    if (album.photoCount! > 0) {
      // Navigate to PhotoGalleryScreen with the album.id
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PhotoGalleryScreen(albumId: album.id)));
    } else {
      setState(() {
        displayedTitle = album.name;
        currentAlbum = album.id;
        filteredCategories = allCategories
            .where((cat) => cat.parentAlbumId == album.id)
            .toList();
      });
    }
  }

  /*
  void fetchAlbumsWithParentId(String? parentAlbumId) async {
    setState(() => isLoading = true);
    try {
      final response = await ApiManager.get<List<dynamic>>('api/albums', getHeaders());
      final albums = response.map((albumJson) => Category.fromJson(albumJson)).toList();

      years = albums
          .map((album) => album.year)
          .whereType<int>()
          .toSet()
          .toList();
      years.sort();

      setState(() {
        // Filter albums with the same parentAlbumId
        filteredCategories = albums.where((album) => album.parentAlbumId == parentAlbumId).toList();
        isLoading = false;
      });
      onSearchChanged(); // Update filtered categories after fetching
    } catch (e) {
      print("Error fetching albums: $e");
      setState(() => isLoading = false);
    }
  }
*/

  @override
  Widget build(BuildContext context) {
    return Menu(
      title: const Text(
        'Albums',
        style: TextStyle(color: Colors.white),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  displayedTitle,
                  style: currentAlbum == null
                      ? const TextStyle(
                          fontWeight:
                              FontWeight.normal) // Main screen title style
                      : const TextStyle(fontWeight: FontWeight.bold),
                  // Sub-album title style
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (years.isNotEmpty)
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: selectedSortYear,
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedSortYear = newValue;
                        filteredCategories = filterCategories();
                      });
                    },
                    items: years.map<DropdownMenuItem<int>>((int year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString(),
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          leading: currentAlbum != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: goBackToParentAlbum,
                )
              : null,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search for albums...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                ),
              ),
            ),
            if (years.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text("Select Year"),
                  value: selectedSortYear,
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedSortYear = newValue;
                      filteredCategories = filterCategories();
                    });
                  },
                  items: years.map<DropdownMenuItem<int>>((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                ),
              ),
            ],
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        String formattedAlbumName = formatText(category.name);

                        const maxLength = 20;
                        if (formattedAlbumName.length > maxLength) {
                          formattedAlbumName =
                              '${formattedAlbumName.substring(0, maxLength - 2)}...';
                        }

                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => onAlbumClicked(category),
                                child: category.coverPhotoId != null
                                    ? Image.asset(
                                        'assets/photos/${category.coverPhotoId}',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Image.asset(
                                        'assets/photos/folderIcon.png',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  color: Colors.black.withOpacity(0.7),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    formattedAlbumName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0.0,
                                right: 0.0,
                                child: Container(
                                  padding: EdgeInsets.all(0.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(0.0),
                                      bottomRight: Radius.circular(0.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        iconSize: 20.0,
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () =>
                                            editAlbum(context, category, index),
                                      ),
                                      const SizedBox(width: 0.0),
                                      IconButton(
                                        iconSize: 20.0,
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            showDeleteConfirmationDialog(
                                                category.name,
                                                category.id,
                                                index),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: addCategory,
              heroTag: 'addCategoryHeroTag',
              child: const Icon(Icons.add),
            ),
            const SizedBox(width: 8.0),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddPictureScreen()),
                );
              },
              backgroundColor: mainColor,
              tooltip: 'Add Photos',
              heroTag: 'addPhotoHeroTag',
              child: const Icon(Icons.photo_camera, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
