<script>
  import { onMount } from 'svelte';
  import HomePage from 'src/features/system/home/index.svelte';
  import { getUrlParam, getMenuPathFromUrlParam } from 'src/lib/url-util';
  import ProgressBar from 'src/components/ui/progress-bar/index.svelte';
  import { AppStore } from 'src/store/app';
  import { SettingsStore } from 'src/store/settings';
  import { BehaviorSubject } from 'rxjs';

  let loading$ = new BehaviorSubject(true);
  onMount(() => {
    AppStore.urlParam = location.href;
    const urlDepartmentId = getUrlParam('d');
    const urlMenuPath = getMenuPathFromUrlParam();

    if (urlDepartmentId && urlMenuPath) {
      SettingsStore.saveUserSettings(
        {
          keys: ['departmentId', 'menuPath'],
          values: [`${urlDepartmentId}`, urlMenuPath],
        },
        false,
      ).then(() => {
        // load last usersettings
        SettingsStore.getLastUserSettings().then(() => loading$.next(false));
      });
    } else {
      // load last usersettings
      SettingsStore.getLastUserSettings().then(() => loading$.next(false));
    }
  });
</script>

{#if $loading$}
  <ProgressBar {loading$} />
{:else}
  <HomePage />
{/if}
