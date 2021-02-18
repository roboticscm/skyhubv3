import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'package:get/get.dart';
import 'package:protobuf/protobuf.dart';
import 'package:skyone_mobile/modules/pages/role/form/controller.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pb.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/edit_button.dart';
import 'package:skyone_mobile/widgets/save_button.dart';
import 'package:skyone_mobile/widgets/scheckbox.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';

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
    _roleFormController.init().then((value) {
      if (isUpdateMode) {
        _roleFormController.isReadOnlyMode.value = true;
        _codeController.text = selectedData.code;
        _nameController.text = selectedData.name;
        _sortController.text = selectedData.sort?.toString() ?? '';
        _disabled = selectedData.disabled;
        _roleFormController.selectedOrgId.value = selectedData.orgId.toInt();
      } else {
        _roleFormController.isReadOnlyMode.value = false;
        _codeController.text = "";
        _nameController.text = "";
        _sortController.text = "1";
        _disabled = false;
        _roleFormController.selectedOrgId.value = null;
      }
    });

    _nameController.addListener(() {
      _roleFormController.name.value = _nameController.text;
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildButtons(context),
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(
              errorText: _roleFormController.codeError.value,
              labelText: 'SYS.LABEL.CODE'.t(),
            ),
          ),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              errorText: _roleFormController.nameError.value,
              labelText: 'SYS.LABEL.NAME'.t(),
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
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      children: [
        if (_roleFormController.isReadOnlyMode.value)
          EditButton(
            onTap: () {
              _roleFormController.isReadOnlyMode.value = !_roleFormController.isReadOnlyMode.value;
            },
          ),
        if (!_roleFormController.isReadOnlyMode.value)
          SaveButton(
            isSaveMode: !isUpdateMode,
            onTap: () {
              Role newObject;
              if (isUpdateMode) {
                newObject = selectedData.deepCopy();
                newObject.name = _nameController.text.trim();
              } else {
                newObject = Role();
              }
              Navigator.of(context).pop(newObject);
            },
          )
      ],
    );
  }

  List<FindBranchResponseItem> _getSubDataNode(int pId) {
    return _roleFormController.orgTree.where((e) => e.pId == pId).toList();
  }

  List<Node> _createNodes(int pId) {
    final List<Node> nodes = [];
    final dataNodes = _getSubDataNode(pId);
    if (dataNodes.isNotEmpty) {
      for (final row in dataNodes) {
        final node = Node(
          key: '${row.id}:${row.type ?? 0}',
          label: row.name,
          expanded: true,
          icon: _roleFormController.selectedOrgId.value == row.id.toInt() ? NodeIcon.fromIconData(Icons.check) : null,
          children: _createNodes(row.id.toInt()),
        );
        nodes.add(node);
      }
    }
    return nodes;
  }

  Widget _buildOrgTree(BuildContext context) {
    final nodes = _createNodes(0);
    final _treeViewController = TreeViewController(children: nodes);
    return TreeView(
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
