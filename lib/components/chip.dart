import "package:flutter/material.dart";

class RoleChip extends StatefulWidget {
  const RoleChip({
    Key? key,
    required this.onTap,
    required this.role,
  }) : super(key: key);
  final void Function(bool) onTap;
  final String role;

  @override
  State<RoleChip> createState() => _ChipState();
}

class _ChipState extends State<RoleChip> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
            selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
          ),
        ),
        onPressed: () => setState(() {
          selected = !selected;
          widget.onTap(selected);
        }),
        child: Text(
          widget.role,
          style: Theme.of(context).textTheme.button?.copyWith(
                color: selected
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}
