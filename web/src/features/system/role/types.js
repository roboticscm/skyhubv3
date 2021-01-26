import { GenericType } from 'src/lib/types';

export class Role extends GenericType {
  constructor() {
    super();
    this.code = '';
    this.name = '';
    this.orgId = undefined;
  }
}
