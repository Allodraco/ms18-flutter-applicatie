import 'package:flutter/material.dart';
import 'package:ms18_applicatie/Widgets/buttons.dart';
import 'package:ms18_applicatie/Widgets/inputFields.dart';
import 'package:ms18_applicatie/Widgets/paddingSpacing.dart';
import 'package:ms18_applicatie/config.dart';

class PageHeader extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  final Function()? onAdd;
  final Function(String value)? onSearch;
  PageHeader({super.key, this.onAdd, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return PagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 7,
                child: InputField(
                  isUnderlineBorder: false,
                  icon: Icons.search,
                  hintText: "Zoeken",
                  onChange: (value) {
                    if (onSearch != null) {
                      onSearch!(value ?? '');
                    }
                  },
                ),
              ),
              if (onAdd != null) ...[
                const PaddingSpacing(),
                Expanded(flex: 3, child: Button(onTap: onAdd!, icon: Icons.add))
              ]
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            color: secondColor,
            height: 1,
          ),
        ],
      ),
    );
  }
}
