<script>
  import { onDestroy, tick, createEventDispatcher } from 'svelte';
  import { genUUID } from 'src/lib/random';

  export let id = genUUID();
  export let data = undefined;
  export let data$ = undefined;
  export let disabled = false;
  export let isCheckableNode = false;
  export let radioType = undefined;

  const dispatch = createEventDispatcher();

  let _data = [];

  const noDataImage = require('../../../../public/images/no-data-found.png').default;

  const setFontCss = (treeId, treeNode) => {
    const body = document.querySelector('body[class^="theme-"]');
    // let highlightColor = getComputedStyle(body)
    //   .getPropertyValue('--my-active-color')
    //   .trim();
    return treeNode.done === true ? { color: highlightColor } : {};
  };

  export const getTreeInstance = () => {
    return window['$'].fn.zTree.getZTreeObj(id);
  };

  export const selectNodeById = (id, fireClickEvent = false) => {
    const treeObj = getTreeInstance();
    if (treeObj && id) {
      const nodes = treeObj.getNodesByParam('id', id.toString(), null);
      if (nodes && nodes.length > 0) {
        treeObj.selectNode(nodes[0]);
        if (fireClickEvent) {
          dispatch('click', { event: {}, treeId: id, treeNode: nodes[0] });
        }
      }
    }
  };

  export const checkNodeById = (id, fireClickEvent = false) => {
    for (let row of _data) {
      if (row.id && id && row.id.toString() === id.toString()) {
        row.checked = true;
      } else {
        row.checked = false;
      }
    }
    _data = [..._data];
  };

  export const checkNodeByIds = (ids, fireClickEvent = false) => {
    for (let row of _data) {
      if (ids.indexOf(row.id) >= 0) {
        row.checked = true;
      } else {
        row.checked = false;
      }
    }
    _data = [..._data];
  };

  export const getSelectedNode = () => {
    const treeObj = getTreeInstance();

    let nodes = treeObj && treeObj.getSelectedNodes();

    if (nodes && nodes.length > 0) {
      return nodes[0];
    } else {
      return undefined;
    }
  };

  export const getNodeById = (id) => {
    const treeObj = getTreeInstance();
    if (treeObj && id) {
      const nodes = treeObj.getNodesByParam('id', id.toString(), null);
      if (nodes && nodes.length > 0) {
        return nodes[0];
      }
    }

    return undefined;
  };

  export const getCheckedLeafIds = (checked = true) => {
    const treeObj = getTreeInstance();
    let nodes = treeObj && treeObj.getCheckedNodes(checked);

    if (nodes && nodes.length > 0) {
      return nodes.filter((node) => !node.isParent).map((node) => node.id.toString());
    } else {
      return [];
    }
  };

  export const getCheckedLeafNodes = (checked = true) => {
    const treeObj = getTreeInstance();
    let nodes = treeObj && treeObj.getCheckedNodes(checked);

    if (nodes && nodes.length > 0) {
      return nodes.filter((node) => !node.isParent);
    } else {
      return [];
    }
  };

  export const getCheckedIds = (checked = true) => {
    const treeObj = getTreeInstance();
    let nodes = treeObj && treeObj.getCheckedNodes(checked);

    if (nodes && nodes.length > 0) {
      return nodes.map((node) => node.id.toString());
    } else {
      return [];
    }
  };

  export const hasCheckChild = (parentNode) => {
    const treeObj = getTreeInstance();

    const nodes = treeObj.transformToArray(parentNode);
    for (let i = 0, l = nodes.length; i < l; i++) {
      if (nodes[i].checked) {
        return true;
      }
    }
    return false;
  };

  export const getCheckedIdsParent = () => {
    const treeObj = getTreeInstance();

    const rootNodes = treeObj && treeObj.getNodes();
    const result = [];
    if (rootNodes) {
      const nodes = treeObj.transformToArray(rootNodes);
      for (let i = 0, l = nodes.length; i < l; i++) {
        if ((nodes[i].isParent && hasCheckChild(nodes[i])) || nodes[i].checked) {
          result.push(nodes[i].id.toString());
        }
      }
    }

    return result;
  };

  export const getCheckedNodes = (checked = true) => {
    const treeObj = getTreeInstance();
    return treeObj && treeObj.getCheckedNodes(checked);
  };

  export const getCheckedData = (checked = true) => {
    const checkedIds = getCheckedIds(true);
    if (!checkedIds) {
      return undefined;
    }

    return _data.filter((it) => checkedIds.indexOf(it.id.toString()) >= 0);
  };

  export const getCheckedDataParent = (checked = true) => {
    const checkedIds = getCheckedIdsParent();
    if (!checkedIds) {
      return undefined;
    }

    return _data.filter((it) => checkedIds.indexOf(it.id.toString()) >= 0);
  };

  export const disableTree = (disable) => {
    const treeObj = getTreeInstance();

    const rootNodes = treeObj && treeObj.getNodes();

    if (rootNodes) {
      const nodes = treeObj.transformToArray(rootNodes);
      for (let i = 0, l = nodes.length; i < l; i++) {
        // nodes[i].nocheck = disable;
        treeObj.setChkDisabled(nodes[i], disable);
      }
      // treeObj.refresh();
    }
  };

  export const clearSelection = () => {
    const treeObj = getTreeInstance();
    if (treeObj) {
      treeObj.cancelSelectedNode();
    }
  };

  export const cleanTree = () => {
    const treeObj = getTreeInstance();

    const rootNodes = treeObj && treeObj.getNodes();
    if (rootNodes) {
      const nodes = treeObj.transformToArray(rootNodes);
      for (let i = 0, l = nodes.length; i < l; i++) {
        treeObj.removeNode(nodes[i]);
      }
    }
  };

  // @ts-ignore
  $: {
    tick().then(() => disableTree(disabled));
  }

  // @ts-ignore
  $: {
    window['$'].fn.zTree.destroy(window['$']('#' + id));
    const setting = {
      check: {
        enable: isCheckableNode || radioType,
        chkStyle: isCheckableNode ? 'checkbox' : radioType ? 'radio' : '',
        radioType,
        nocheckInherit: true,
      },
      view: {
        fontCss: setFontCss,
      },
      data: {
        simpleData: {
          enable: true,
        },
      },
      callback: {
        onClick: (event, treeId, treeNode) => {
          dispatch('click', { event, treeId, treeNode });
        },
        onCheck: (event, treeId, treeNode) => {
          dispatch('check', { event, treeId, treeNode });
        },
      },
    };

    tick().then(() => {
      window['$'].fn.zTree.init(window['$']('#' + id), setting, _data);
    });

    tick().then(() => disableTree(disabled));
  }

  // @ts-ignore
  $: {
    if (data) {
      _data = data;
      // @ts-ignore
    } else if ($data$) {
      // @ts-ignore
      _data = $data$;
    }
  }

  onDestroy(() => {
    window['$'].fn.zTree.destroy(window['$']('#' + id));
  });
</script>

<div class="tree-wrapper">
  <slot name="label" />
  <ul {id} class="stree ztree" />
  {#if !_data || _data.length === 0}
    <div class="no-data">
      <img src={noDataImage} alt="" />
    </div>
  {/if}
</div>
