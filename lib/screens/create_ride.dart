import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:tawseleh/api/firebase_api.dart';
import 'package:tawseleh/provider/create_ride_provider.dart';
import 'package:tawseleh/widgets/custom_appbar.dart';

import '../api/image_api.dart';
import '../model/city_model.dart';
import '../utils/constants.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({Key? key}) : super(key: key);

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {

  var _departureController=TextEditingController();
  var _arrivalController=TextEditingController();
  var _dateController=TextEditingController();
  var _timeController=TextEditingController();
  var _priceController=TextEditingController();
  var _seatsController=TextEditingController();
  String arrival='';

  String selectedGender='Male'.tr();
  String gender='Male';
  List<String> genders = <String>['Male'.tr(), 'Female'.tr()];

  DateTime startDate=DateTime.now();
  DateTime endDate=DateTime.now().add(Duration(days: 7));
 /* Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(3000),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        _dateController.text = df.format(picked);
      });
    }
  }*/
  String url="";
  final _formKey = GlobalKey<FormState>();

  Future imageModalBottomSheet(context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.cloud_upload),
                    title: Text('Upload Picture'.tr()),
                    onTap: () => {
                      ImageHandler.chooseGallery().then((value) async{
                        if(value!=null){
                          print("not null");
                          String imageUrl=await ImageHandler.uploadImageToFirebase(context, value);
                          print("url path $imageUrl");
                          setState(() {
                            print(imageUrl);
                            url=imageUrl;
                          });

                        }
                        Navigator.pop(context);
                      })
                    }),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text('Take a photo'.tr()),
                  onTap: () => {
                    ImageHandler.chooseCamera().then((value) async{
                      if(value!=null){
                        String imageUrl=await ImageHandler.uploadImageToFirebase(context, value);
                        setState(() {
                          url=imageUrl;
                        });
                      }

                      Navigator.pop(context);
                    })
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      final provider = Provider.of<CreateRideProvider>(context, listen: false);
      provider.reset();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(

          children: [
            CustomAppBar(title: 'Create a Ride'.tr()),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(10),
                  children: [
                    InkWell(
                      onTap: (){
                        print("url $url");
                        imageModalBottomSheet(context);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height*0.25,
                        width: MediaQuery.of(context).size.width,

                        child: url==""?DottedBorder(
                            color: primaryColor,
                            strokeWidth: 1,
                            dashPattern: [7],
                            borderType: BorderType.Rect,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              width: MediaQuery.of(context).size.width,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/upload.png",color: primaryColor,height: 50,width: 50,fit: BoxFit.cover,),
                                  SizedBox(height: 10,),
                                  Text('Upload Car Picture'.tr(),style: TextStyle(color: primaryColor,fontWeight: FontWeight.w300),)
                                ],
                              ),
                            )
                        ):Image.network(url,fit: BoxFit.cover,),
                      ),
                    ),
                    const SizedBox(height: 15,),

                    const SizedBox(height: 15,),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text'.tr();
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: (){
                        showCityDialog(true);
                      },
                      controller: _departureController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Departure Destination'.tr(),
                        // If  you are using latest version of flutter then lable text and hint text shown like this
                        // if you r using flutter less then 1.20.* then maybe this is not working properly
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text'.tr();
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: (){
                        showCityDialog(false);
                      },
                      onChanged: (value){
                        print('arr val $value');
                        _arrivalController.text=value.tr();
                      },
                      controller: _arrivalController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Arrival Destination'.tr(),
                        // If  you are using latest version of flutter then lable text and hint text shown like this
                        // if you r using flutter less then 1.20.* then maybe this is not working properly
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text'.tr();
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: ()async{
                        final range =await showDateRangePicker(
                          context: context,

                          currentDate: DateTime.now(),
                          initialDateRange: DateTimeRange(start: startDate, end: endDate),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2050),
                        );
                        if (range != null) {
                          setState(() {
                            startDate=range.start;
                            endDate=range.end;
                          });

                          _dateController.text='${df.format(range.start)} - ${df.format(range.end)}';

                        }
                        //_selectDate(context);
                      },
                      controller: _dateController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Date'.tr(),
                        // If  you are using latest version of flutter then lable text and hint text shown like this
                        // if you r using flutter less then 1.20.* then maybe this is not working properly
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text'.tr();
                        }
                        return null;
                      },
                      readOnly: true,
                      onTap: () async {
                        final result = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(startDate),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: child!,
                              );
                            }
                        );
                        if (result != null) {
                          setState(() {

                            DateTime dateTime = startDate;
                            startDate = DateTime(dateTime.year, dateTime.month, dateTime.day, result.hour, result.minute);
                            DateTime dateTime2 = endDate;
                            endDate = DateTime(dateTime2.year, dateTime2.month, dateTime2.day, result.hour, result.minute);
                            _timeController.text=tf.format(startDate);

                          });


                        }
                      },
                      controller: _timeController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Time'.tr(),
                        // If  you are using latest version of flutter then lable text and hint text shown like this
                        // if you r using flutter less then 1.20.* then maybe this is not working properly
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text'.tr();
                        }
                        return null;
                      },
                      onChanged: (value){
                        if(value.isNotEmpty){
                          if(int.parse(value)>60){
                            _seatsController.text=60.toString();
                          }
                        }

                      },
                      controller: _seatsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Available Seat'.tr(),
                        // If  you are using latest version of flutter then lable text and hint text shown like this
                        // if you r using flutter less then 1.20.* then maybe this is not working properly
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text'.tr();
                        }
                        return null;
                      },
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 0.5
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 0.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Price Per Seat'.tr(),
                        // If  you are using latest version of flutter then lable text and hint text shown like this
                        // if you r using flutter less then 1.20.* then maybe this is not working properly
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(7)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10,0,15,0),
                        child: DropdownButton<String>(
                          value: selectedGender,
                          icon: const Icon(Icons.arrow_drop_down,color: Colors.black),
                          elevation: 16,
                          isExpanded: true,
                          underline: Container(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedGender = value!;
                              if(selectedGender==genders.first){
                                gender='Male';
                              }
                              else{
                                gender='Female';
                              }
                            });
                          },
                          items: genders.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,

                              child: Text(value,style: const TextStyle(color:  Colors.black, ),),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30,),
                    Center(
                      child: InkWell(
                        onTap: ()async{


                          if(_formKey.currentState!.validate()){
                            if(url==''){
                              CoolAlert.show(
                                context: context,
                                type: CoolAlertType.error,
                                text: 'Upload Car Picture'.tr(),
                              );
                            }
                            else{
                              final ProgressDialog pr = ProgressDialog(context: context);
                              pr.show(max: 100, msg: 'Please Wait'.tr());
                              final provider = Provider.of<CreateRideProvider>(context, listen: false);

                              await FirebaseFirestore.instance.collection('rides').add({
                                'userId':FirebaseAuth.instance.currentUser!.uid,
                                'departureCity':getCity(provider.departure),
                                'departureNeighbour':getNeighbour(provider.departure),
                                'arrivalCity':getCity(provider.arrival),
                                'arrivalNeighbour':getNeighbour(provider.arrival),
                                'date':_dateController.text,
                                'startDateInMilli':startDate.millisecondsSinceEpoch,
                                'endDateInMilli':endDate.millisecondsSinceEpoch,
                                'time':_timeController.text,
                                'seats':int.parse(_seatsController.text),
                                'pricePerSeat':double.parse(_priceController.text),
                                'image':url,
                                'gender':gender,
                              }).then((value){
                                pr.close();
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.success,
                                  onConfirmBtnTap: (){
                                    Navigator.pop(context);
                                  },
                                  text: 'Rides Created'.tr(),
                                );
                              }).onError((error, stackTrace) {
                                pr.close();
                                CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.error,
                                  text: error.toString(),
                                );
                              });
                            }


                          }
                        },
                        child: Container(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          alignment: Alignment.center,
                          child: Text('Publish'.tr(),style: TextStyle(fontSize:16,color: Colors.white),),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<void> showCityDialog(bool departure){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context,setState){
              return Dialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                insetAnimationDuration: const Duration(seconds: 1),
                insetAnimationCurve: Curves.fastOutSlowIn,
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*0.7,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(


                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(15),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 0.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Search'.tr(),
                              // If  you are using latest version of flutter then lable text and hint text shown like this
                              // if you r using flutter less then 1.20.* then maybe this is not working properly
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          noItemsFoundBuilder: (context) {
                            return ListTile(
                              leading: Icon(Icons.error),
                              title: Text('No Data Found'.tr()),
                            );
                          },
                          suggestionsCallback: (pattern) async {

                            List<CityModel> search=[];
                            await FirebaseFirestore.instance
                                .collection('cities').orderBy('name',descending: false)
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) {
                                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                                CityModel model=CityModel.fromMap(data, doc.reference.id);
                                if (model.name.contains(pattern))
                                  search.add(model);
                              });
                            });

                            return search;
                          },
                          itemBuilder: (context, CityModel suggestion) {
                            return ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(suggestion.name.tr()),
                            );
                          },
                          onSuggestionSelected: (CityModel suggestion) {
                            //_countryController.text=suggestion.name;

                            Navigator.pop(context);
                            showNeighbourDialog(suggestion,departure);

                          },
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('cities').orderBy('name',descending: false).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    const Text("Something Went Wrong",style: TextStyle(color: Colors.black))

                                  ],
                                ),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data!.size==0){
                              return Center(
                                  child: Text('No Data Found'.tr(),style: TextStyle(color: Colors.black))
                              );

                            }

                            return ListView(
                              shrinkWrap: true,
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: ListTile(
                                    onTap: (){
                                      Navigator.pop(context);
                                      showNeighbourDialog(CityModel.fromMap(data, document.reference.id),departure);



                                    },
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text('${data['name']}'.tr(),style: const TextStyle(color: Colors.black),),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }

  Future<void> showNeighbourDialog(CityModel city,bool departure){
    return showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
            builder: (context,setState){
              return Dialog(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
                insetAnimationDuration: const Duration(seconds: 1),
                insetAnimationCurve: Curves.fastOutSlowIn,
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height*0.7,
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        margin: const EdgeInsets.all(10),
                        child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(


                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(15),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 0.5
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 0.5,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'Search'.tr(),
                              // If  you are using latest version of flutter then lable text and hint text shown like this
                              // if you r using flutter less then 1.20.* then maybe this is not working properly
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                            ),
                          ),
                          noItemsFoundBuilder: (context) {
                            return ListTile(
                              leading: Icon(Icons.error),
                              title: Text('No Data Found'.tr()),
                            );
                          },
                          suggestionsCallback: (pattern) async {

                            List<CityModel> search=[];
                            await FirebaseFirestore.instance
                                .collection('cities').doc(city.id).collection('neighborhood').orderBy('name',descending: false)
                                .get()
                                .then((QuerySnapshot querySnapshot) {
                              querySnapshot.docs.forEach((doc) {
                                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                                CityModel model=CityModel.fromMap(data, doc.reference.id);
                                if (model.name.contains(pattern))
                                  search.add(model);
                              });
                            });

                            return search;
                          },
                          itemBuilder: (context, CityModel suggestion) {
                            return ListTile(
                              leading: const Icon(Icons.place_outlined),
                              title: Text(suggestion.name.tr()),
                            );
                          },
                          onSuggestionSelected: (CityModel suggestion) {
                            final provider = Provider.of<CreateRideProvider>(context, listen: false);
                            setState(() {
                              if(departure){
                                provider.setDeparture('${city.name}:${suggestion.name}');
                                _departureController.text='${suggestion.name.toString().tr()}, ${city.name.tr()}';
                              }
                              else{
                                provider.setArrival('${city.name}:${suggestion.name}');
                                _arrivalController.text='${suggestion.name.toString().tr()}, ${city.name.tr()}';
                              }
                            });
                            Navigator.pop(context);

                          },
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('cities').doc(city.id).collection('neighborhood').orderBy('name',descending: false).snapshots(),
                          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  children: [
                                    const Text("Something Went Wrong",style: TextStyle(color: Colors.black))

                                  ],
                                ),
                              );
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.data!.size==0){
                              return Center(
                                  child: Text('No Data Found'.tr(),style: TextStyle(color: Colors.black))
                              );

                            }

                            return ListView(
                              shrinkWrap: true,
                              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: ListTile(
                                    onTap: (){
                                      final provider = Provider.of<CreateRideProvider>(context, listen: false);

                                      setState(() {
                                        if(departure){

                                          _departureController.text='${data['name'].toString().tr()}, ${city.name.tr()}';
                                          provider.setDeparture('${city.name}:${data['name']}');
                                        }
                                        else{
                                          provider.setArrival('${city.name}:${data['name']}');
                                          _arrivalController.text='${data['name'].toString().tr()}, ${city.name.tr()}';
                                        }
                                      });
                                      Navigator.pop(context);
                                    },
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text('${data['name']}'.tr(),style: const TextStyle(color: Colors.black),),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
    );
  }
}
