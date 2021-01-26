<script>
  import OrgIconMark from 'src/icons/org-mark.svelte';
  import ChangeBranchModal from './components/change-branch-modal/index.svelte';
  import { LoginInfo } from 'src/store/login-info';
  import { App } from 'src/lib/constants';
  import { T } from 'src/lib/locale';
  import { SettingsStore } from 'src/store/settings';

  const { branchId$, branchName$, companyName$ } = LoginInfo;
  let changeBranchModalRef;

  const showChangeBranchModal = () => {
    changeBranchModalRef && changeBranchModalRef.show();
  };

  $: if ($branchId$) {
    SettingsStore.getUserSettings({
      keys: ['theme'],
    }).then((res) => {
      if (res.data && res.data.length > 0) {
        LoginInfo.theme$.next(res.data[0].value);
      } else {
        LoginInfo.theme$.next('ivory');
      }
    });
  }
</script>

<ChangeBranchModal bind:this={changeBranchModalRef} />
<div class="branch" on:click={showChangeBranchModal}>
  <div class="branch__logo" style="display: flex; align-content: center; align-items: center;">
    <OrgIconMark />
  </div>
  {#if $branchName$}
    <div title={$companyName$} class="branch__name">
      {@html $branchName$}
    </div>
  {:else if $branchName$ === undefined}
    {@html App.PROGRESS_BAR}
  {:else}{T('SYS.LABEL.NO_DEPARTMENT_AVAILABLE')}{/if}
</div>
