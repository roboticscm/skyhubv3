import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_treeview/tree_view.dart' as tree;
import 'package:get/get.dart';
import 'package:skyone_mobile/modules/pages/role/form/controller.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pb.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/util/form_item.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/edit_button.dart';
import 'package:skyone_mobile/widgets/scheckbox.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';
import 'package:skyone_mobile/widgets/upsert_button.dart';

class RoleForm extends StatelessWidget {
  final String module;
  final Role selectedData;
  final bool isUpdateMode;
  final _roleFormController = Get.put(RoleFormController());
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _sortController = TextEditingController();
  bool _disabled = false;

  RoleForm({this.module, this.selectedData, this.isUpdateMode}) {
    _codeController.addListener(() {
      _roleFormController.code.value = FormItemString(value: _codeController.text.trim());
    });

    _nameController.addListener(() {
      _roleFormController.name.value = FormItemString(value: _nameController.text.trim());
    });

    _roleFormController.init().then((value) {
      if (isUpdateMode) {
        _roleFormController.isReadOnlyMode.value = true;
      } else {
        _roleFormController.isReadOnlyMode.value = false;

        selectedData.code = "";
        selectedData.name = "";
        selectedData.sort = 1;
        selectedData.disabled = false;
        selectedData.orgId = null;
      }



      _codeController.text = selectedData.code;
      _nameController.text = selectedData.name;
      _sortController.text = "${selectedData.sort ?? 1}";
      _disabled = selectedData.disabled;
      _roleFormController.selectedOrgId.value = selectedData.orgId?.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isUpdateMode ? "${'SYS.LABEL.UPDATE'.t()} $module" : "${'SYS.LABEL.ADD_NEW'.t()} $module"),
        ),
        body: Padding(
          padding: defaultPadding,
          child: Obx(() {
            if (_roleFormController.isLoading.value) {
              return Center(child: SCircularProgressIndicator.buildSmallCenter());
            } else {
              return _buildForm(context);
            }
          }),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        _buildButtons(context),
        Expanded(
          child: SingleChildScrollView(
            child: IgnorePointer(
              ignoring: _roleFormController.isReadOnlyMode.value,
              child: Column(
                children: [
                  TextFormField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      errorText: _roleFormController.code.value.error,
                      labelText: 'SYS.LABEL.CODE'.t(),
                    ),
                  ),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (value) => print("aaaa $value"),
                    decoration: InputDecoration(
                      errorText: _roleFormController.name.value.error,
                      labelText: "${'SYS.LABEL.NAME'.t()} (*)",
                    ),
                  ),
                  TextFormField(
                    controller: _sortController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'SYS.LABEL.SORT'.t(),
                    ),
                  ),
                  SCheckbox(
                      onChanged: (bool value) {
                        _disabled = value;
                      },
                      checked: _disabled,
                      text: 'SYS.LABEL.DISABLED'.t()),
                  _buildOrgTree(context)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        if (_roleFormController.isReadOnlyMode.value)
          EditButton(
            onPressed: () {
              _roleFormController.isReadOnlyMode.value = !_roleFormController.isReadOnlyMode.value;
            },
          ),
        if (!_roleFormController.isReadOnlyMode.value)
          UpsertButton(
              showText: true,
              isUpdateMode: isUpdateMode,
              isLoading: _roleFormController.isUpsertLoading,
              onPressed: !_roleFormController.formValid
                  ? null
                  : () => _roleFormController.upsertHandler(
                      context: context, selectedData: selectedData, isUpdateMode: isUpdateMode))
      ],
    );
  }

  List<FindBranchResponseItem> _getSubDataNode(int pId) {
    return _roleFormController.orgTree.where((e) => e.pId == pId).toList();
  }

  List<tree.Node> _createNodes(int pId) {
    final List<tree.Node> nodes = [];
    final dataNodes = _getSubDataNode(pId);
    if (dataNodes.isNotEmpty) {
      for (final row in dataNodes) {
        final node = tree.Node(
          key: '${row.id}:${row.type ?? 0}',
          label: row.name,
          expanded: true,
          icon: _roleFormController.selectedOrgId.value == row.id.toInt()
              ? tree.NodeIcon.fromIconData(Icons.check)
              : null,
          children: _createNodes(row.id.toInt()),
        );
        nodes.add(node);
      }
    }
    return nodes;
  }

  Widget _buildOrgTree(BuildContext context) {
    final nodes = _createNodes(0);
    final _treeViewController = tree.TreeViewController(children: nodes);
    return tree.TreeView(
        controller: _treeViewController,
        allowParentSelect: true,
        supportParentDoubleTap: false,
        shrinkWrap: true,
        onNodeTap: (key) {
          final split = key.split(":");
          if (int.tryParse(split[1]) == 10) {
            _roleFormController.selectedOrgId.value = int.tryParse(split[0]);
          }
        });
  }
}
