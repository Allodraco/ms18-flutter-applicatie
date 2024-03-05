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
  bool areDetailsAndNavBarVisible = false;
  bool isEditing = false;
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.currentIndex);
    _titleController.text = widget.photos[widget.currentIndex].title;

    // Toegevoegd: Voeg een listener toe om de oriëntatieveranderingen te detecteren
    WidgetsBinding.instance?.addObserver(
        OrientationChangeObserver(_handleOrientationChange));
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    // Toegevoegd: Verwijder de oriëntatielissener
    WidgetsBinding.instance?.removeObserver(
        OrientationChangeObserver(_handleOrientationChange));
    super.dispose();
  }

  // Toegevoegd: Functie om te reageren op oriëntatieveranderingen
  void _handleOrientationChange() {
    setState(() {
      if (MediaQuery
          .of(context)
          .orientation == Orientation.landscape) {
        areDetailsAndNavBarVisible = true;
      } else {
        areDetailsAndNavBarVisible = false;
      }
    });
  }

  void _toggleEdit() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        widget.photos[widget.currentIndex].updateTitle(_titleController.text);
      }
    });
  }

  void _toggleVisibility() {
    setState(() {
      areDetailsAndNavBarVisible = !areDetailsAndNavBarVisible;

      // Exit edit mode if details are hidden
      if (!areDetailsAndNavBarVisible && isEditing) {
        _toggleEdit();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery
        .of(context)
        .orientation == Orientation.portrait;

    return Scaffold(
      body: GestureDetector(
        onTap: () => _toggleVisibility(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (int index) {
                setState(() {
                  widget.currentIndex = index;
                  _titleController.text = widget.photos[index].title;
                });
              },
              itemBuilder: (context, index) {
                Photo photo = widget.photos[index];
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    photo.imageUrl,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
            if (areDetailsAndNavBarVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  title: Text(
                    'Foto informatie',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.black.withOpacity(0.8),
                  iconTheme: IconThemeData(color: Colors.white),
                ),
              ),
            if (areDetailsAndNavBarVisible)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isPortrait
                        ? _buildPortraitLayout()
                        : _buildLandscapeLayout(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    String titleToShow = isEditing
        ? 'Wijzig Titel'
        : widget.photos[widget.currentIndex].title;

    if (titleToShow.length > 30) {
      // Afkappen van de titel als deze langer is dan 20 tekens
      titleToShow = '${titleToShow.substring(0, 28)}...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titleToShow,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
          Column(
            children: [
              SizedBox(height: 15),
              TextField(
                controller: _titleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Titel',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        SizedBox(height: 5),
        ElevatedButton(
          onPressed: () => _toggleEdit(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: Text(
            isEditing ? 'Opslaan' : 'Wijzig Titel',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    String titleToShow = isEditing
        ? 'Wijzig Titel'
        : widget.photos[widget.currentIndex].title;

    if (titleToShow.length > 43) {
      // Afkappen van de titel als deze langer is dan 30 tekens
      titleToShow = '${titleToShow.substring(0, 41)}...';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titleToShow,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  '${widget.photos[widget.currentIndex].likeCount}',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
            SizedBox(width: 16),
            Text(
              'Jaar: ${widget.photos[widget.currentIndex].date.year}',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => _toggleEdit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text(
                isEditing ? 'Opslaan' : 'Wijzig Titel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 0),
        if (isEditing)
          TextField(
            controller: _titleController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Titel',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
          ),
      ],
    );
  }
}

// Toegevoegd: Observer voor oriëntatieveranderingen
class OrientationChangeObserver extends WidgetsBindingObserver {
  final Function() onOrientationChange;

  OrientationChangeObserver(this.onOrientationChange);

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    onOrientationChange();
  }
}
