import "package:flutter/material.dart";

class RoleChip extends StatefulWidget {
  const RoleChip({
    Key? key,
    required this.onTap,
    required this.role,
    required this.selected,
    required this.disabled,
    required this.onLongPress,
  }) : super(key: key);
  final void Function(bool) onTap;
  final void Function() onLongPress;
  final String role;
  final bool disabled;
  final bool selected;

  @override
  State<RoleChip> createState() => _ChipState();
}

class _ChipState extends State<RoleChip> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 10.0,
        bottom: 10.0,
      ),
      child: ElevatedButton(
        style: ButtonStyle(
          maximumSize: MaterialStateProperty.all<Size>(
            Size(double.infinity, MediaQuery.of(context).size.height * 0.05),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.all(10.0),
          ),
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
            widget.selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
          ),
        ),
        onPressed: widget.disabled ? null : () => widget.onTap(widget.selected),
        onLongPress: widget.disabled ? null : widget.onLongPress,
        child: Text(
          widget.role,
          style: Theme.of(context).textTheme.button?.copyWith(
                color: widget.selected
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}
