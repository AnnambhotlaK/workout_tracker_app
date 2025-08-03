import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetTile extends StatefulWidget {
  final String initialWeight;
  final String initialReps;
  final bool isCompleted;
  final ValueChanged<bool?> onCheckboxChanged;
  final Function(String newWeight)
      onWeightChanged; // Callback for weight update
  final Function(String newReps) onRepsChanged; // Callback for reps update

  const SetTile({
    super.key,
    required this.initialWeight,
    required this.initialReps,
    required this.isCompleted,
    required this.onCheckboxChanged,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  @override
  _SetTileState createState() => _SetTileState();
}

class _SetTileState extends State<SetTile> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late FocusNode _weightFocusNode;
  late FocusNode _repsFocusNode;

  @override
  void initState() {
    super.initState();
    // init weight and reps fields with previous weight/reps
    _weightController = TextEditingController(text: widget.initialWeight);
    _repsController = TextEditingController(text: widget.initialReps);
    _weightFocusNode = FocusNode();
    _repsFocusNode = FocusNode();

    // Optional: Add listeners to save on focus change (lost focus)
    _weightFocusNode.addListener(() {
      if (!_weightFocusNode.hasFocus &&
          _weightController.text != widget.initialWeight) {
        widget.onWeightChanged(_weightController.text);
      }
      if (_weightFocusNode.hasFocus) {
        _weightController.selection = TextSelection(baseOffset: 0, extentOffset: _weightController.text.length);
      }
    });
    _repsFocusNode.addListener(() {
      if (!_repsFocusNode.hasFocus &&
          _repsController.text != widget.initialReps) {
        widget.onRepsChanged(_repsController.text);
      }
      if (_repsFocusNode.hasFocus) {
        _repsController.selection = TextSelection(baseOffset: 0, extentOffset: _repsController.text.length);
      }
    });
  }

  @override
  void didUpdateWidget(covariant SetTile oldWidget) {
    // If weight or reps change elsewhere from WorkoutData, update here
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWeight != widget.initialWeight ||
        oldWidget.initialReps != widget.initialReps) {
      _weightController.text = widget.initialWeight;
      _repsController.text = widget.initialReps;
    }
  }

  @override
  void dispose() {
    // Discard unused resources
    _weightController.dispose();
    _repsController.dispose();
    _weightFocusNode.dispose();
    _repsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      textColor: Colors.white,
      leading: Checkbox(
        value: widget.isCompleted,
        onChanged: widget.onCheckboxChanged,
      ),
      title: Padding(
        padding: EdgeInsetsGeometry.only(bottom: 5),
        child: Row(
          children: [

            // WEIGHT TEXT BOX
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(19, 0, 0, 0),
            ),
            Expanded(
              child: TextFormField(
                controller: _weightController,
                focusNode: _weightFocusNode,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  // Allow numbers and one decimal
                ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 2.0, horizontal: 4.0),
                  hintText: "0",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent), borderRadius: BorderRadius.circular(5)),
                  fillColor: Colors.blue[100],
                  filled: true,
                ),
                onFieldSubmitted: (value) {
                  // Save when user presses "done" on keyboard
                  widget.onWeightChanged(value);
                  _weightFocusNode.unfocus(); // Optionally unfocus
                },
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(35, 0, 0, 0),
            ),
            Expanded(
              child: TextFormField(
                controller: _repsController,
                focusNode: _repsFocusNode,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                // Allow only digits
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                  hintText: "0",
                  hintStyle: TextStyle(color: Colors.grey),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                  fillColor: Colors.red[100],
                  filled: true,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(5)),
                ),
                onFieldSubmitted: (value) {
                  widget.onRepsChanged(value);
                  _repsFocusNode.unfocus();
                },
              ),
            ),
          ],
        ),
      ),
      dense: true,
    );
  }
}
