<script>
  import { App } from 'src/lib/constants';
  import { T } from 'src/lib/locale';
  import { SettingsStore } from 'src/store/settings';
  import DropdownItem from 'src/components/ui/dropdown-item/index.svelte';
  import DepIconMark from 'src/icons/dep-mark.svelte';
  import { Dropdown } from 'src/lib/dropdown';
  import { OrgStore } from 'src/features/system/org/store';
  import { LoginInfo } from 'src/store/login-info';
  import { MenuStore } from 'src/features/system/menu/store';

  const { departments$ } = OrgStore;
  const { departmentId$ } = LoginInfo;
  const { branchId$ } = LoginInfo;

  $: if ($branchId$) {
    OrgStore.findRoledDepartments($branchId$).subscribe(() => {
      OrgStore.getLastRoledDepartmentId($branchId$).subscribe((res) => {
        if (res.data && res.data.length > 0) {
          departmentId$.next(`${res.data[0].depId}`);
        }
      });
    });
  }

  $: if ($departmentId$) {
    MenuStore.findRoledMenu($departmentId$).subscribe(() => {
      saveUserSettings();
    });
  }

  const getSelectedDepartment = (departmentId) => {
    if ($departments$) {
      return $departments$.find((it) => it.id == departmentId) || { name: '' };
    }
    return {};
  };

  let firstTime = true;
  const saveUserSettings = () => {
    Promise.all([
      SettingsStore.saveUserSettings(
        {
          keys: ['departmentId'],
          values: [`${$departmentId$}`],
        },
        false,
      ),

      SettingsStore.saveUserSettings({
        keys: ['departmentId'],
        values: [`${$departmentId$}`],
      }),
    ]).then(() => {
      if (!firstTime) {
        window.location.reload();
      }
      firstTime = false;
    });
  };
  const onNavigate = (event, department) => {
    departmentId$.next(department.id);
    Dropdown.hide('moduleDropdownId');
  };

  const onMouseover = () => {
    Dropdown.show('moduleDropdownId');
  };

  const onMouseout = () => {
    Dropdown.hide('moduleDropdownId');
  };
</script>

<div class="modules">
  <div>
    {#if $departments$ && $departments$.length > 0}
      <div class="modules__content">
        <DepIconMark on:mouseover={onMouseover} on:mouseout={onMouseout}>
          <div id="moduleDropdownId" class="dropdown-content">
            {#each $departments$ as dep, index}
              <DropdownItem on:click={(e) => onNavigate(e, dep)} text={dep.name} selected={dep.id === $departmentId$} />
            {/each}
          </div>
        </DepIconMark>
        <span class="modules__content__name">
          {@html ' ' + getSelectedDepartment($departmentId$).name}
        </span>
      </div>
    {:else if $departments$ && $departments$.length === 0}
      {T('SYS.LABEL.NO_DEPARTMENT_AVAILABLE')}
    {:else}
      {@html App.PROGRESS_BAR}
    {/if}
  </div>
</div>
