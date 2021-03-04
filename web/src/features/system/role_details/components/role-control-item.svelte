<script>
  import CheckBox from 'src/components/ui/input/checkbox';
  import { App } from 'src/lib/constants';
  import FloatSelect from 'src/components/ui/float-input/select';

  export let role;
  export let orgMenu;
  export let roleControlDetails;
  export let roleDetail;

  const dataLevels = [
      {id: 1, name: 'SYS.LABEL.CORPORATION'.t()},
      {id: 10, name: 'SYS.LABEL.COMPANY'.t()},
      {id: 100, name: 'SYS.LABEL.BRANCH'.t()},
      {id: 1000, name: 'SYS.LABEL.DEPARTMENT'.t()},
      {id: 10000, name: 'SYS.LABEL.DEFAULT'.t()},
  ];
</script>

<style lang="scss">
  .new {
    background: var(--notify-bgcolor);
  }
</style>

<div class="default-padding default-rounded-border">
  <div style="display: flex; justify-content: space-between; flex-wrap: nowrap">
    <div style="display: flex; flex-wrap: nowrap">
      {`${role.name}${orgMenu.grandParentName2 ? ' - ' + orgMenu.grandParentName2 : ''}${orgMenu.grandParentName ? ' \\ ' + orgMenu.grandParentName : ''}${orgMenu.parentName ? ' \\ ' + orgMenu.parentName : ''} - ${orgMenu.menuName}`}
    </div>

    <div style="white-space: nowrap; text-align: right">
      <CheckBox text={'SYS.LABEL.PRIVATE'.t()} bind:checked={roleDetail.isPrivate} />
      <CheckBox text={'SYS.LABEL.APPROVE'.t()} bind:checked={roleDetail.approve} />
    </div>
  </div>

  <div style="display: flex; justify-content: space-between; flex-wrap: nowrap">
    <FloatSelect className="dense-floating-select" placeholder = {'SYS.LABEL.DATA_LEVEL'.t()} bind:value={roleDetail.dataLevel} data = {dataLevels}></FloatSelect>
  </div>

 
  {#if roleControlDetails && roleControlDetails.length >= 0}
    <table>
      <tr>
        <th>{'SYS.LABEL.CONTROL'.t()}</th>
        <th>{'SYS.LABEL.RENDER'.t()}</th>
        <th>{'SYS.LABEL.DISABLE'.t()}</th>
        <th>{'SYS.LABEL.CONFIRM'.t()}</th>
        <th>{'SYS.LABEL.REQUIRE_PASSWORD'.t()}</th>
      </tr>
      {#each roleControlDetails as control}
        <tr class={control.found ? '' : 'new'}>
          <td>{control.controlName}</td>
          <td>
            <CheckBox bind:checked={control.renderControl} />
          </td>
          <td>
            <CheckBox bind:checked={control.disableControl} />
          </td>
          <td>
            <CheckBox bind:checked={control.confirm} />
          </td>
          <td>
            <CheckBox bind:checked={control.requirePassword} />
          </td>
        </tr>
      {/each}
    </table>
  {:else}
    {@html App.PROGRESS_BAR}
  {/if}
</div>
