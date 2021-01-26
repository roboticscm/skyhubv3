import { BehaviorSubject } from 'rxjs';

export class LoginInfo {
  static companyId$ = new BehaviorSubject();
  static companyName$ = new BehaviorSubject();
  static branchId$ = new BehaviorSubject();
  static branchName$ = new BehaviorSubject();
  static locale$ = new BehaviorSubject();
  static theme$ = new BehaviorSubject('ivory');
  static departmentId$ = new BehaviorSubject();
  static menuPath$ = new BehaviorSubject();
  static ip = new BehaviorSubject();

  static getUserId = () =>
    localStorage.getItem('remember') === 'true' ? localStorage.getItem('userId') : sessionStorage.getItem('userId');
}
