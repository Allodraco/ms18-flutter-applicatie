import 'package:flutter/material.dart';
import 'photo.dart';

Color mainColor = Color(0xFF15233d);

class PhotoDetailScreen extends StatefulWidget {
  final List<Photo> photos;
  int currentIndex;

  PhotoDetailScreen({
    Key? key,
    required this.photos,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _PhotoDetailScreenState createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late PageController _controller;
  bool isDetailsVisible = false;
  bool isEditing = false;
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.currentIndex);
    _titleController.text = widget.photos[widget.currentIndex].title;
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        widget.photos[widget.currentIndex].updateTitle(_titleController.text);
      }
    });
  }

  void _toggleDetails() {
    setState(() {
      isDetailsVisible = !isDetailsVisible;

      // Exit edit mode if details are hidden
      if (!isDetailsVisible && isEditing) {
        _toggleEdit();
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Foto informatie'),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.photos.length,
                onPageChanged: (int index) {
                  setState(() {
                    // Close edit mode when switching photos
                    if (isEditing) {
                      _toggleEdit();
                    }

                    widget.currentIndex = index;
                    _titleController.text = widget.photos[index].title;
                  });
                },


                itemBuilder: (context, index) {
                  Photo photo = widget.photos[index];
                  return Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _toggleDetails(),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.network(
                            photo.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (isDetailsVisible)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        isEditing ? 'Wijzig Titel' : widget.photos[widget.currentIndex].title,
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.favorite, color: Colors.red),
                                          SizedBox(width: 4),
                                          Text(
                                            '${widget.photos[widget.currentIndex].likeCount}',
                                            style: TextStyle(fontSize: 16, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Jaar: ${widget.photos[widget.currentIndex].date.year}',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  if (isEditing)
                                    TextField(
                                      controller: _titleController,
                                      style: TextStyle(color: Colors.white), // Set text color to white
                                      decoration: InputDecoration(
                                        labelText: 'Titel',
                                        labelStyle: TextStyle(color: Colors.white),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ElevatedButton(
                                    onPressed: () => _toggleEdit(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Text(isEditing ? 'Opslaan' : 'Wijzig Titel', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
