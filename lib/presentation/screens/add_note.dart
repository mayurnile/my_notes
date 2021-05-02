import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_notes/core/core.dart';
import 'package:my_notes/core/models/models.dart';
import 'package:my_notes/presentation/widgets/widgets.dart';
import 'package:my_notes/providers/notes_provider.dart';

class AddNotescreen extends StatefulWidget {
  final Note note;
  final bool isEdit;

  AddNotescreen({
    Key key,
    this.note,
    @required this.isEdit,
  }) : super(key: key);

  @override
  _AddNotescreenState createState() => _AddNotescreenState();
}

class _AddNotescreenState extends State<AddNotescreen> {
  final _formKey = GlobalKey<FormState>();

  String _title;
  String _description;
  String _imagePath;
  File _image;
  bool _editedImage = false;

  ImagePicker _imagePicker;
  bool _isLoading;

  Size screenSize;
  TextTheme textTheme;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      _title = widget.note.title;
      _description = widget.note.description;
      _imagePath = widget.note.imagePath;
    } else {
      _title = '';
      _description = '';
    }
    _isLoading = false;
    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22.0, 12.0, 22.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //appBar
                  _buildAppBar(),
                  //new note form
                  _buildNoteForm(),
                  //display image
                  _buildImageView(),
                  //spacing
                  SizedBox(height: screenSize.height * 0.03),
                  //actions
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //back button
        InkWell(
          onTap: () => locator.get<NavigationService>().navigateBack(),
          child: SvgPicture.asset(
            Assets.BACK,
            width: 32.0,
            height: 32.0,
          ),
        ),
        //spacing
        SizedBox(width: 18.0),
        //title
        Text(
          widget.isEdit ? 'Edit Note' : 'Add New Note',
          style: textTheme.headline2,
        ),
      ],
    );
  }

  Widget _buildNoteForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //spacing
          SizedBox(height: screenSize.height * 0.03),
          //title input
          MyTextField(
            hint: 'Enter Title',
            inputType: TextInputType.text,
            initialValue: _title,
            onSaved: (String value) => _title = value.trim(),
            validator: (String value) {
              if (value.trim().length == 0) {
                return 'This field cannot be empty !';
              }
            },
          ),
          //spacing
          SizedBox(height: screenSize.height * 0.01),
          //description input
          MyTextField(
            hint: 'Enter Description',
            inputType: TextInputType.multiline,
            initialValue: _description,
            onSaved: (String value) => _description = value.trim(),
            maxLines: 5,
            validator: (String value) {
              if (value.trim().length == 0) {
                return 'This field cannot be empty !';
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageView() {
    if (widget.isEdit && _editedImage == false) {
      return _imagePath != null
          ? Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  _imagePath,
                  width: screenSize.width,
                  height: screenSize.height * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : SizedBox.shrink();
    }
    return _image != null
        ? Padding(
            padding: const EdgeInsets.only(top: 22.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                _image,
                width: screenSize.width,
                height: screenSize.height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
          )
        : SizedBox.shrink();
  }

  Widget _buildActions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //attach / remove button
        widget.isEdit && _editedImage == false
            ? _imagePath == null
                ? SizedBox(
                    width: (screenSize.width / 2) - 32.0,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        primary: MyNotesTheme.CARD_COLOR,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //icon
                          SvgPicture.asset(Assets.ATTACH),
                          //spacing
                          SizedBox(width: 8.0),
                          //text
                          Text(
                            'Attach Image',
                            style: textTheme.headline5
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    width: (screenSize.width / 2) - 32.0,
                    child: ElevatedButton(
                      onPressed: _removeImage,
                      style: ElevatedButton.styleFrom(
                        primary: MyNotesTheme.CARD_COLOR,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //icon
                          SvgPicture.asset(Assets.REMOVE),
                          //spacing
                          SizedBox(width: 8.0),
                          //text
                          Text(
                            'Remove Image',
                            style: textTheme.headline5
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  )
            : _image == null
                ? SizedBox(
                    width: (screenSize.width / 2) - 32.0,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        primary: MyNotesTheme.CARD_COLOR,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //icon
                          SvgPicture.asset(Assets.ATTACH),
                          //spacing
                          SizedBox(width: 8.0),
                          //text
                          Text(
                            'Attach Image',
                            style: textTheme.headline5
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox(
                    width: (screenSize.width / 2) - 32.0,
                    child: ElevatedButton(
                      onPressed: _removeImage,
                      style: ElevatedButton.styleFrom(
                        primary: MyNotesTheme.CARD_COLOR,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //icon
                          SvgPicture.asset(Assets.REMOVE),
                          //spacing
                          SizedBox(width: 8.0),
                          //text
                          Text(
                            'Remove Image',
                            style: textTheme.headline5
                                .copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
        //save button
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SizedBox(
                width: (screenSize.width / 2) - 32.0,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //icon
                      SvgPicture.asset(Assets.SAVE),
                      //spacing
                      SizedBox(width: 8.0),
                      //text
                      Text(
                        'Save',
                        style:
                            textTheme.headline5.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
      ],
    );
  }

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.all(22.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              //heading
              Text(
                'Options',
                style: textTheme.headline3,
              ),
              //spacing
              SizedBox(height: screenSize.height * 0.02),
              //options
              OptionButton(
                icon: Assets.GALLERY,
                title: 'Pick From Gallery',
                onPressed: () async {
                  print('executing');
                  final pickedFile =
                      await _imagePicker.getImage(source: ImageSource.gallery);

                  setState(() {
                    if (pickedFile != null) {
                      _editedImage = true;
                      _image = File(pickedFile.path);
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
              //divider
              Divider(
                color: MyNotesTheme.FONT_LIGHT_COLOR,
                indent: 32.0,
                endIndent: 32.0,
              ),
              OptionButton(
                icon: Assets.CAMERA,
                title: 'Capture Now',
                onPressed: () async {
                  final pickedFile =
                      await _imagePicker.getImage(source: ImageSource.camera);

                  setState(() {
                    if (pickedFile != null) {
                      _editedImage = true;
                      _image = File(pickedFile.path);
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
      _image = null;
    });
  }

  void _saveNote() async {
    setState(() {
      _isLoading = true;
    });

    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();

      NotesProvider _notesProvider = Get.find();

      if (widget.isEdit) {
        Note editedNote = Note(
          id: widget.note.id,
          title: _title,
          description: _description,
          imagePath: widget.note.imagePath,
          createdTime: DateTime.now(),
        );

        final result = await _notesProvider.editNote(editedNote, _image);

        if (result) {
          Fluttertoast.showToast(msg: 'Note Edited !');
          locator.get<NavigationService>().navigateBack();
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(msg: 'Something went wrong !');
        }
      } else {
        final result = await _notesProvider.createNewNote(
          _title,
          _description,
          _image,
        );

        if (result) {
          Fluttertoast.showToast(msg: 'Note Created !');
          locator.get<NavigationService>().navigateBack();
        } else {
          Fluttertoast.showToast(msg: 'Something went wrong !');
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }
}
