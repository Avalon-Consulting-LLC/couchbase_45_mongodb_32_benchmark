rsconf = {
	_id: "rs" + id,
		members: [
      			{
        			_id: 0,
        			host: primary + ":27017",
				priority: 5
      			}
    		]
  	}

rs.initiate(rsconf)
