import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_notes/core/core.dart';
import 'package:my_notes/core/models/models.dart';
import 'package:my_notes/presentation/widgets/widgets.dart';
import 'package:my_notes/providers/auth_provider.dart';
import 'package:my_notes/providers/notes_provider.dart';

class AddNotescreen extends StatefulWidget {
  final Note? note;
  final bool isEdit;

  const AddNotescreen({
    Key? key,
    this.note,
    required this.isEdit,
  }) : super(key: key);

  @override
  _AddNotescreenState createState() => _AddNotescreenState();
}

class _AddNotescreenState extends State<AddNotescreen> {
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _description;
  String? _imagePath;
  File? _image;
  bool _editedImage = false;

  late ImagePicker _imagePicker;
  bool _isLoading = true;

  late Size screenSize;
  late TextTheme textTheme;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit && widget.note != null) {
      _title = widget.note!.title;
      _description = widget.note!.description;
      _imagePath = widget.note!.imagePath;
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
            physics: const BouncingScrollPhysics(),
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
      children: [
        //back button
        InkWell(
          onTap: () => locator.get<NavigationService>().navigateBack(),
          child: SvgPicture.asset(
            Assets.back,
            width: 32.0,
            height: 32.0,
          ),
        ),
        //spacing
        const SizedBox(width: 18.0),
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
            onSaved: (String? value) {
              if (value != null) _title = value.trim();
            },
            validator: (String? value) {
              if (value != null && value.trim().isEmpty) {
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
            onSaved: (String? value) {
              if (value != null) _description = value.trim();
            },
            maxLines: 5,
            validator: (String? value) {
              if (value != null && value.trim().isEmpty) {
                return 'This field cannot be empty !';
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageView() {
    if (widget.isEdit && _imagePath != null && _editedImage == false) {
      return _imagePath!.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  _imagePath!,
                  width: screenSize.width,
                  height: screenSize.height * 0.3,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : const SizedBox.shrink();
    }
    return _image != null
        ? Padding(
            padding: const EdgeInsets.only(top: 22.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.file(
                _image!,
                width: screenSize.width,
                height: screenSize.height * 0.3,
                fit: BoxFit.cover,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //attach / remove button
        if (widget.isEdit && _imagePath != null && _editedImage == false)
          _imagePath!.isEmpty
              ? SizedBox(
                  width: (screenSize.width / 2) - 32.0,
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      primary: MyNotesTheme.cardColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        SvgPicture.asset(Assets.attach),
                        //spacing
                        const SizedBox(width: 8.0),
                        //text
                        Text(
                          'Attach Image',
                          style: textTheme.headline5!.copyWith(color: Colors.black),
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
                      primary: MyNotesTheme.cardColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        SvgPicture.asset(Assets.remove),
                        //spacing
                        const SizedBox(width: 8.0),
                        //text
                        Text(
                          'Remove Image',
                          style: textTheme.headline5!.copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                )
        else
          _image == null
              ? SizedBox(
                  width: (screenSize.width / 2) - 32.0,
                  child: ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      primary: MyNotesTheme.cardColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        SvgPicture.asset(Assets.attach),
                        //spacing
                        const SizedBox(width: 8.0),
                        //text
                        Text(
                          'Attach Image',
                          style: textTheme.headline5!.copyWith(color: Colors.black),
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
                      primary: MyNotesTheme.cardColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //icon
                        SvgPicture.asset(Assets.remove),
                        //spacing
                        const SizedBox(width: 8.0),
                        //text
                        Text(
                          'Remove Image',
                          style: textTheme.headline5!.copyWith(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
        //save button
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(MyNotesTheme.primaryColor),
            ),
          )
        else
          SizedBox(
            width: (screenSize.width / 2) - 32.0,
            child: ElevatedButton(
              onPressed: _saveNote,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //icon
                  SvgPicture.asset(Assets.save),
                  //spacing
                  const SizedBox(width: 8.0),
                  //text
                  Text(
                    'Save',
                    style: textTheme.headline5!.copyWith(color: Colors.white),
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
          decoration: const BoxDecoration(
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
                icon: Assets.gallery,
                title: 'Pick From Gallery',
                onPressed: () async {
                  final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);

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
              const Divider(
                color: MyNotesTheme.fontLightColor,
                indent: 32.0,
                endIndent: 32.0,
              ),
              OptionButton(
                icon: Assets.camera,
                title: 'Capture Now',
                onPressed: () async {
                  final pickedFile = await _imagePicker.getImage(source: ImageSource.camera);

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

  Future<void> _saveNote() async {
    setState(() {
      _isLoading = true;
    });

    final form = _formKey.currentState;

    if (form!.validate()) {
      form.save();

      final NotesProvider _notesProvider = Get.find();

      if (widget.isEdit && widget.note != null) {
        final Note editedNote = Note(
          id: widget.note!.id,
          title: _title!,
          description: _description!,
          imagePath: widget.note!.imagePath,
          createdTime: DateTime.now(),
        );

        final result = await _notesProvider.editNote(
          editedNote: editedNote,
          image: _image,
        );

        if (result) {
          Fluttertoast.showToast(msg: 'Note Edited !');
          locator.get<NavigationService>().navigateBack();
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(msg: 'Something went wrong !');
        }
      } else {
        final AuthProvider _authProvider = Get.find();

        final result = await _notesProvider.createNewNote(
          firestore: _notesProvider.firestore,
          firebaseStorage: _notesProvider.firebaseStorage,
          userID: _authProvider.userId ?? '',
          title: _title!,
          description: _description!,
          image: _image,
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
