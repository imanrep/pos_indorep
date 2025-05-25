import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:collection/collection.dart';

class EditMenuViewHelpers {
  static Future<void> updateMenu(
    AddMenuRequest newMenu,
    List<OptionMenuIrep> originalOptions,
    List<OptionMenuIrep> currentOptions,
    List<int> deletedOptionValues,
    MenuProvider provider,
  ) async {
    final res = await provider.editMenu(newMenu);
    if (!res.success) return;

    await _deleteRemovedValues(deletedOptionValues, provider);
    await _syncOptions(
        newMenu.menuId!, originalOptions, currentOptions, provider);
  }

  static Future<void> addNewMenu(
    AddMenuRequest newMenu,
    List<OptionMenuIrep> currentOptions,
    MenuProvider provider,
  ) async {
    final res = await provider.addMenu(newMenu);
    if (!res.success) return;

    await _addOptionsToMenu(res.menuId, currentOptions, provider);
  }

  static Future<void> _deleteRemovedValues(
    List<int> deletedOptionValues,
    MenuProvider provider,
  ) async {
    for (var id in deletedOptionValues) {
      await provider.deleteOptionValue(id);
    }
  }

  static Future<void> _syncOptions(
    int menuId,
    List<OptionMenuIrep> originalOptions,
    List<OptionMenuIrep> currentOptions,
    MenuProvider provider,
  ) async {
    final newOptions = _getNewOptions(originalOptions, currentOptions);
    final deletedOptions = _getDeletedOptions(originalOptions, currentOptions);
    final editedOptions = _getEditedOptions(originalOptions, currentOptions);

    for (var option in deletedOptions) {
      await provider.deleteOption(option.optionId);
    }

    for (var option in newOptions) {
      await _addOptionToMenu(menuId, option, provider);
    }

    for (var option in editedOptions) {
      await _editOption(option, provider);

      final original =
          originalOptions.firstWhere((o) => o.optionId == option.optionId);
      await _syncOptionValues(original, option, provider);
    }

    await _syncNewOptionValues(originalOptions, currentOptions, provider);
  }

  static Future<void> _syncNewOptionValues(
    List<OptionMenuIrep> original,
    List<OptionMenuIrep> current,
    MenuProvider provider,
  ) async {
    final originalIds = original
        .expand((o) => o.optionValue.map((v) => v.optionValueId))
        .toSet();

    for (var option in current) {
      for (var value in option.optionValue) {
        if (!originalIds.contains(value.optionValueId)) {
          await provider.addOptionValue(AddOptionValueRequest(
            menuOptionId: option.optionId,
            optionValueName: value.optionValueName,
            amount: value.optionValuePrice,
          ));
        }
      }
    }
  }

  static Future<void> _syncOptionValues(
    OptionMenuIrep original,
    OptionMenuIrep current,
    MenuProvider provider,
  ) async {
    final originalValues = original.optionValue;
    final currentValues = current.optionValue;

    final deleted = originalValues.where(
        (o) => !currentValues.any((c) => c.optionValueId == o.optionValueId));
    for (var val in deleted) {
      await provider.deleteOptionValue(val.optionValueId);
    }

    final edited = currentValues.where((c) {
      final orig = originalValues
          .firstWhereOrNull((o) => o.optionValueId == c.optionValueId);
      return orig != null &&
          (orig.optionValueName != c.optionValueName ||
              orig.optionValuePrice != c.optionValuePrice);
    });

    for (var val in edited) {
      await provider.editOptionValue(EditOptionValueRequest(
        id: val.optionValueId,
        optionValueName: val.optionValueName,
        amount: val.optionValuePrice,
      ));
    }
  }

  static Future<void> _addOptionsToMenu(
    int menuId,
    List<OptionMenuIrep> options,
    MenuProvider provider,
  ) async {
    for (var option in options) {
      await _addOptionToMenu(menuId, option, provider);
    }
  }

  static Future<void> _addOptionToMenu(
    int menuId,
    OptionMenuIrep option,
    MenuProvider provider,
  ) async {
    final res = await provider.addOption(AddOptionRequest(
      menuId: menuId,
      optionName: option.optionName,
      optionType: option.optionType,
      optionAvailable: option.available,
    ));

    if (res.success) {
      for (var val in option.optionValue) {
        await provider.addOptionValue(AddOptionValueRequest(
          menuOptionId: res.optionId,
          optionValueName: val.optionValueName,
          amount: val.optionValuePrice,
        ));
      }
    }
  }

  static Future<void> _editOption(
    OptionMenuIrep option,
    MenuProvider provider,
  ) async {
    await provider.editOption(EditOptionRequest(
      id: option.optionId,
      optionName: option.optionName,
      optionType: option.optionType,
      optionAvailable: option.available,
    ));
  }

  static List<OptionMenuIrep> _getNewOptions(
    List<OptionMenuIrep> original,
    List<OptionMenuIrep> current,
  ) =>
      current
          .where((o) => !original.any((orig) => orig.optionId == o.optionId))
          .toList();

  static List<OptionMenuIrep> _getDeletedOptions(
    List<OptionMenuIrep> original,
    List<OptionMenuIrep> current,
  ) =>
      original
          .where((o) => !current.any((cur) => cur.optionId == o.optionId))
          .toList();

  static List<OptionMenuIrep> _getEditedOptions(
    List<OptionMenuIrep> original,
    List<OptionMenuIrep> current,
  ) =>
      current.where((cur) {
        final orig =
            original.firstWhereOrNull((o) => o.optionId == cur.optionId);
        return orig != null &&
            (orig.optionName != cur.optionName ||
                orig.optionType != cur.optionType ||
                orig.available != cur.available);
      }).toList();
}
