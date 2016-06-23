for (i = 0; i < 12; i++) {
	var index = {}
	index["field" + i] = 1
	db.usertable.createIndex(index)
}
