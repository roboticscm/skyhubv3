<script>
  import { onMount } from 'svelte';
  import HomePage from 'src/features/system/home/index.svelte';
  import { getUrlParam, getMenuPathFromUrlParam } from 'src/lib/url-util';
  import ProgressBar from 'src/components/ui/progress-bar/index.svelte';
  import { AppStore } from 'src/store/app';
  import { SettingsStore } from 'src/store/settings';
  import { BehaviorSubject } from 'rxjs';
  import NoRole from './no-role.svelte';

  let loading$ = new BehaviorSubject(true);
  let isValid = false;
  let message;

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
        SettingsStore.getLastUserSettings()
          .then(() => {
            loading$.next(false);
            isValid = true;
          })
          .catch((err) => {
            loading$.next(false);
            message = err;
          });
      });
    } else {
      // load last usersettings
      SettingsStore.getLastUserSettings()
        .then(() => {
          loading$.next(false);
          isValid = true;
        })
        .catch((err) => {
          loading$.next(false);
          message = err;
        });
    }
  });
</script>

{#if $loading$}
  <ProgressBar {loading$} />
{:else if isValid}
  <HomePage />
{/if}

{#if message !== undefined}
  <NoRole {message} />
{/if}
