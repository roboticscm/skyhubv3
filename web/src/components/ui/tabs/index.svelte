<script>
  import { onMount } from 'svelte';
  import { SettingsStore } from 'src/store/settings';

  export let titleKeys = [];
  export let activeTab;
  export let saveState = false;
  export let id;

  let toggleTabViewRef;

  const openTab = (titleKey) => {
    activeTab = titleKey;
    if (saveState) {
      SettingsStore.saveUserSettings({
        elementId: id,
        menuPath: 'system/profile',
        keys: ['activeTab'],
        values: [activeTab],
      });
    }
  };

  const toggleTabView = () => {};

  onMount(() => {
    if (titleKeys.length > 0) {
      if (saveState) {
        SettingsStore.findUserSettings({
          elementId: id,
          menuPath: 'system/profile',
          key: 'activeTab',
        }).then((res) => {
          if (res && res.length > 0) {
            activeTab = res[0].value;
          }
        });
      }

      if (!activeTab) {
        activeTab = titleKeys[0];
      }
    }
  });
</script>

<div class="tabs-container">
  <ul class="tabs-container__tabs">
    {#each titleKeys as titleKey}
      <li class="tabs-container__tabs__item {activeTab === titleKey ? 'tabs-container__tabs__item__active' : ''}">
        <div class="tabs-container__tabs__item__title" on:click={openTab(titleKey)}>
          {('SYS.LABEL.' + titleKey).t()}
        </div>
      </li>
    {/each}
  </ul>
</div>
<div>
  <slot />
</div>
