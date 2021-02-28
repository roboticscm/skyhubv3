<script>
    import CheckBox from 'src/components/ui/input/checkbox';

  export let role;
  export let orgMenu;
</script>

<div class="default-padding default-rounded-border">
  <div>{`${role.name}${orgMenu.grandParentName2 ? ' - ' + orgMenu.grandParentName2 : ''}${orgMenu.grandParentName ? ' \\ ' + orgMenu.grandParentName : ''}${orgMenu.parentName ? ' \\ ' + orgMenu.parentName : ''}`}</div>
  {#if orgMenu.controlList && orgMenu.controlList.length > 0}
    <table>
      <tr>
        <th>{'SYS.LABEL.CONTROL'.t()}</th>
        <th>{'SYS.LABEL.RENDER'.t()}</th>
        <th>{'SYS.LABEL.DISABLE'.t()}</th>
      </tr>
      {#each orgMenu.controlList as control}
        <tr>
          <td>{control.controlName}</td>
          <td><CheckBox></CheckBox></td>
          <td><CheckBox></CheckBox></td>
        </tr>
      {/each}
    </table>
  {/if}
</div>
