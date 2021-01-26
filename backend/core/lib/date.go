package lib

import "github.com/astaxie/beego/orm"

//GetCurrentMillis function return current date time from database in milliseconds
func GetCurrentMillis() (int64, error) {
	o := orm.NewOrm()
	sql := `SELECT date_generator() as date`

	var maps []orm.Params
	num, err := o.Raw(sql).Values(&maps)
	if err == nil && num > 0 {
		d, _ := ToInt64(maps[0]["date"])
		return d, nil
	}

	return -1, err
}
