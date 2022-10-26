library country_state_city_picker_nona;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'model/select_status_model.dart' as StatusModel;

class SelectState extends StatefulWidget {
  final ValueChanged<String>? onCountryChanged;
  final ValueChanged<String>? onStateChanged;
  final ValueChanged<String>? onCityChanged;
  final VoidCallback? onCountryTap;
  final VoidCallback? onStateTap;
  final VoidCallback? onCityTap;
  final TextStyle? style;
  final Color? dropdownColor;
  final InputDecoration decoration;
  final double spacing;

  final String? defaultCountry;
  final String? defaultState;
  final String countryHint;
  final String stateHint;
  final String cityHint;

  final bool showCountry;
  final bool showState;
  final bool showCity;

  const SelectState(
      {Key? key,
      this.onCountryChanged,
      required this.onStateChanged,
      required this.onCityChanged,
      this.decoration = const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
      this.spacing = 0.0,
      this.style,
      this.dropdownColor,
      this.onCountryTap,
      this.onStateTap,
      this.onCityTap, 
      this.defaultCountry, 
      this.defaultState,
      this.showCountry = true, 
      this.showState = true, 
      this.showCity = true, 
      this.countryHint = "Choose Country", 
      this.stateHint = "Choose State/Province", 
      this.cityHint = "Choose City"
  })
      : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  late List<String> _cities;
  late List<String> _country;
  late String _selectedCity;
  late String _selectedCountry;
  late String _selectedState;
  late List<String> _states;
  var responses;

  @override
  void initState() {

    _cities = [widget.cityHint];
    _country = [widget.countryHint];
    _states = [widget.stateHint];
    _selectedCity = widget.cityHint;
    _selectedCountry = widget.defaultCountry ?? widget.countryHint;
    _selectedState = widget.defaultState ?? widget.stateHint;


    if (widget.defaultCountry != null) {
      getState();
    }

    if (widget.defaultState != null) {
      getCity();
    }

    getCounty();

    super.initState();
  }

  Future getResponse() async {
    var res = await rootBundle.loadString(
        'packages/country_state_city_picker/lib/assets/country.json');
    return jsonDecode(res);
  }

  Future getCounty() async {
    var countryres = await getResponse() as List;
    countryres.forEach((data) {
      var model = StatusModel.StatusModel();
      model.name = data['name'];
      model.emoji = data['emoji'];
      if (!mounted) return;
      setState(() {
        _country.add(model.emoji! + "    " + model.name!);
      });
    });

    return _country;
  }

  Future getState() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => ((item.emoji + "    " + item.name) as String).contains( _selectedCountry))
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      if (!mounted) return;
      setState(() {
        var name = f.map((item) => item.name).toList();
        for (var statename in name) {
          print(statename.toString());

          _states.add(statename.toString());
        }
      });
    });

    return _states;
  }

  Future getCity() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => ((item.emoji + "    " + item.name) as String).contains(_selectedCountry))
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      var name = f.where((item) => item.name == _selectedState);
      var cityname = name.map((item) => item.city).toList();
      cityname.forEach((ci) {
        if (!mounted) return;
        setState(() {
          var citiesname = ci.map((item) => item.name).toList();
          for (var citynames in citiesname) {
            print(citynames.toString());

            _cities.add(citynames.toString());
          }
        });
      });
    });
    return _cities;
  }

  void _onSelectedCountry(String value) {
    if (!mounted) return;
    setState(() {
      _selectedState = "Choose  State/Province";
      _states = ["Choose  State/Province"];
      _selectedCountry = value;
      this.widget.onCountryChanged?.call(value);
      getState();
    });
  }

  void _onSelectedState(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = "Choose City";
      _cities = ["Choose City"];
      _selectedState = value;
      this.widget.onStateChanged?.call(value);
      getCity();
    });
  }

  void _onSelectedCity(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = value;
      this.widget.onCityChanged?.call(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.showCountry) ...[
          InputDecorator(
            decoration: widget.decoration,
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
              dropdownColor: widget.dropdownColor,
              isExpanded: true,
              items: _country.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          dropDownStringItem,
                          style: widget.style,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
              // onTap: ,
              onChanged: (value) => _onSelectedCountry(value!),
              onTap: widget.onCountryTap,
              // onChanged: (value) => _onSelectedCountry(value!),
              value: _selectedCountry,
            )),
          ),
          SizedBox(
            height: widget.spacing,
          ),
        ],
        
        if (widget.showState) ...[
          InputDecorator(
            decoration: widget.decoration,
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
              dropdownColor: widget.dropdownColor,
              isExpanded: true,
              items: _states.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          dropDownStringItem,
                          style: widget.style,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => _onSelectedState(value!),
              onTap: widget.onStateTap,
              value: _selectedState,
            )),
          ),
          SizedBox(
            height: widget.spacing,
          ),
        ],
        
        if (widget.showCity)
          InputDecorator(
            decoration: widget.decoration,
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
              dropdownColor: widget.dropdownColor,
              isExpanded: true,
              items: _cities.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          dropDownStringItem,
                          style: widget.style,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => _onSelectedCity(value!),
              onTap: widget.onCityTap,
              value: _selectedCity,
            )),
          ),
      ],
    );
  }
}
