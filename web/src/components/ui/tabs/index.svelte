<script>
  import { onMount } from 'svelte';

  import { T } from 'src/lib/locale';

  export let titleKeys = [];
  export let activeTab;

  let toggleTabViewRef;

  const openTab = (titleKey) => {
    activeTab = titleKey;
  };

  const toggleTabView = () => {};

  onMount(() => {
    if (titleKeys.length > 0) {
      activeTab = titleKeys[0];
    }
  });
</script>

<div class="tabs-container">
  <ul class="tabs-container__tabs">
    {#each titleKeys as titleKey}
      <li class="tabs-container__tabs__item {activeTab === titleKey ? 'tabs-container__tabs__item__active' : ''}">
        <div class="tabs-container__tabs__item__title" on:click={openTab(titleKey)}>{T('SYS.LABEL.' + titleKey)}</div>
      </li>
    {/each}
  </ul>
</div>
<div>
  <slot />
</div>
