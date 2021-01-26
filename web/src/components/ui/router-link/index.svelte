<script>
  import { routerLinkStore } from './store';
  import { createEventDispatcher } from 'svelte';
  import { T } from 'src/lib/locale';
  import { StringUtil } from 'src/lib/string-util';

  const { currentComponentUri$ } = routerLinkStore;
  const dispatch = createEventDispatcher();

  export let __path = '/';
  export let activeClass = '';
  export let className = 'nav-item';
  export let menuId;
  export let menuName;

  $: name = T(`SYS.MENU.${menuName}`);

  let isActiveComponent;
  $: {
    const uri = StringUtil.replaceAll($currentComponentUri$, '/', '--');
    const path = __path.replace('/', '--') + '--';
    isActiveComponent = uri.includes(path);
  }

  const onClick = (e) => {
    const _path = e.path.replace('--', '/');
    const comUri = `features${_path}/index.svelte`;
    dispatch('navigate', { path: _path, menuId: e.menuId });
    currentComponentUri$.next(comUri);
  };
</script>

<div
  id={__path.replace('/', '')}
  on:click={() => onClick({ path: __path, menuId })}
  class="{className}
  {isActiveComponent ? activeClass : ''}">
  {@html name}
</div>
