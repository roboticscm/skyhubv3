import 'package:flutter/material.dart';
import 'package:flutter_treeview/tree_view.dart' as tree;
import 'package:get/get.dart';
import 'package:skyone_mobile/modules/pages/role/form/controller.dart';
import 'package:skyone_mobile/pt/proto/org/org_service.pb.dart';
import 'package:skyone_mobile/pt/proto/role/role_message.pb.dart';
import 'package:skyone_mobile/extension/string.dart';
import 'package:skyone_mobile/util/form_item.dart';
import 'package:skyone_mobile/util/global_var.dart';
import 'package:skyone_mobile/widgets/edit_button.dart';
import 'package:skyone_mobile/widgets/int_form_field.dart';
import 'package:skyone_mobile/widgets/scheckbox.dart';
import 'package:skyone_mobile/widgets/scircular_progress_indicator.dart';
import 'package:skyone_mobile/widgets/text_form_field.dart';
import 'package:skyone_mobile/widgets/upsert_button.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class RoleForm extends StatelessWidget {
  final String menuPath;
  final int depId;
  final String module;
  Role selectedData;
  final bool isUpdateMode;
  final _roleFormController = Get.put(RoleFormController());

  RoleForm({this.module, this.selectedData, this.isUpdateMode, this.depId, this.menuPath}) {
    _roleFormController.init(depId: depId, menuPath: menuPath).then((value) {
      if (isUpdateMode) {
        _roleFormController.isReadOnlyMode$.value = true;
      } else {
        _roleFormController.isReadOnlyMode$.value = false;
        selectedData = null;
      }

      _roleFormController.disabled$.value = FormItemBool(value: selectedData?.disabled ?? false);
      _roleFormController.selectedOrgId$.value = FormItemInt(value: selectedData?.orgId?.toInt());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isUpdateMode ? "${'SYS.LABEL.UPDATE'.t()} $module" : "${'SYS.LABEL.ADD_NEW'.t()} $module"),
        ),
        body: Builder(
          builder: (BuildContext ctx) => Padding(
            padding: defaultPadding,
            child: GetBuilder(
              builder: (RoleFormController roleFormController) {
                if (roleFormController.isInitializing$.value) {
                  return Center(child: SCircularProgressIndicator.buildSmallCenter());
                } else {
                  return _buildForm(ctx);
                }
              },
              id: 'loading',
            ),
          ),
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
            child: GetBuilder(
              id: 'isReadOnlyMode',
              builder: (RoleFormController roleFormController) => IgnorePointer(
                ignoring: roleFormController.isReadOnlyMode$.value,
                child: Opacity(
                  opacity: roleFormController.isReadOnlyMode$.value ? disableOpacity : 1,
                  child: Column(
                    children: [
                      STextFormField(
                        formItem$: _roleFormController.code$,
                        label: 'SYS.LABEL.CODE'.t(),
                        initialValue: selectedData?.code ?? '',
                      ),
                      STextFormField(
                        formItem$: _roleFormController.name$,
                        label: 'SYS.LABEL.NAME'.t(),
                        required: true,
                        initialValue: selectedData?.name ?? '',
                      ),
                      SIntFormField(
                        formItem$: _roleFormController.sort$,
                        label: 'SYS.LABEL.SORT'.t(),
                        initialValue: selectedData?.sort?.toInt() ?? 1,
                      ),
                      SCheckbox(
                          onChanged: (bool value) {
                            _roleFormController.disabled$.value.value = value;
                          },
                          checked: _roleFormController.disabled$.value.value,
                          text: 'SYS.LABEL.DISABLED'.t()),
                      GetBuilder(
                        id: 'orgId',
                        builder: (RoleFormController controller) => _buildOrgTree(context, controller),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Obx(() => Row(children: [
          if (_roleFormController.isRendered(
              controlCode: "btnEdit", isRendered: _roleFormController.isReadOnlyMode$.value))
            EditButton(
              onPressed: () {
                _roleFormController.toggleEditMode();
              },
            ),
          if (_roleFormController.isRendered(
              controlCode: "btnUpdate", isRendered: !_roleFormController.isReadOnlyMode$.value))
            UpsertButton(
                isUpdateMode: isUpdateMode,
                isLoading: _roleFormController.isUpsertLoading$,
                onPressed: !_roleFormController.formValid
                    ? null
                    : () => _roleFormController.upsertHandler(
                        context: context, selectedData: selectedData, isUpdateMode: isUpdateMode)),
          Expanded(child: Container()),
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showPopupMenu(context, details.globalPosition);
            },
            child: const Icon(Icons.more_vert),
          ),
        ]));
  }

  void _showPopupMenu(BuildContext context, Offset position) async {
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy + 20, 0, 0),
      items: [
        if (_roleFormController.isRendered(controlCode: "btnDelete"))
          PopupMenuItem(
            enabled: !_roleFormController.isDisabled(controlCode: "btnDelete", isDisabled: _roleFormController.isReadOnlyMode$.value),
            value: "btnDelete",
            child: Text("SYS.BUTTON.DELETE".t()),
          ),
        if (_roleFormController.isRendered(controlCode: "btnConfig"))
          PopupMenuItem(
            value: "btnConfig",
            child: Text("SYS.BUTTON.CONFIG".t()),
          ),
        if (_roleFormController.isRendered(controlCode: "btnViewLog"))
          PopupMenuItem(
            value: "btnViewLog",
            child: Text("SYS.BUTTON.VIEW_LOG".t()),
          ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        print(value);
      }
    });
  }

  List<FindBranchResponseItem> _getSubDataNode(int pId) {
    return _roleFormController.orgTree$.where((e) => e.pId == pId).toList();
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
          icon: _roleFormController.selectedOrgId$.value.value == row.id.toInt()
              ? tree.NodeIcon.fromIconData(Icons.check)
              : null,
          children: _createNodes(row.id.toInt()),
        );
        nodes.add(node);
      }
    }
    return nodes;
  }

  Widget _buildOrgTree(BuildContext context, RoleFormController controller) {
    final nodes = _createNodes(0);
    final _treeViewController = tree.TreeViewController(children: nodes);
    return tree.TreeView(
        controller: _treeViewController,
        allowParentSelect: true,
        shrinkWrap: true,
        onNodeTap: (key) {
          final split = key.split(":");
          if (int.tryParse(split[1]) == 10) {
            controller.setOrgId(int.tryParse(split[0]));
          }
        });
  }
}
