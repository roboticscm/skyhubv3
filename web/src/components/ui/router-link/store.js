import { BehaviorSubject } from 'rxjs';

export const routerLinkStore = {
  currentComponentUri$: new BehaviorSubject(''),
};
