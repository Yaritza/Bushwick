  var census = {"01":["Alabama",21830,266],"02":["Alaska",29932,1140],"04":["Arizona",25307,247],"05":["Arkansas",21529,201],"06":["California",25971,104],"08":["Colorado",29237,430],"09":["Connecticut",31920,247],"10":["Delaware",28405,921],"11":["District of Columbia",38014,1708],"12":["Florida",23387,172],"13":["Georgia",24682,253],"15":["Hawaii",29786,621],"16":["Idaho",22166,317],"17":["Illinois",27301,120],"18":["Indiana",24801,269],"19":["Iowa",26717,254],"20":["Kansas",26299,284],"21":["Kentucky",21871,186],"22":["Louisiana",22416,215],"23":["Maine",24367,496],"24":["Maryland",34564,457],"25":["Massachusetts",31016,231],"26":["Michigan",23938,206],"27":["Minnesota",30094,193],"28":["Mississippi",20206,292],"29":["Missouri",23933,251],"30":["Montana",23536,553],"31":["Nebraska",26450,308],"32":["Nevada",26328,314],"33":["New Hampshire",30651,420],"34":["New Jersey",32158,208],"35":["New Mexico",22775,364],"36":["New York",28449,247],"37":["North Carolina",23946,258],"38":["North Dakota",29326,721],"39":["Ohio",24778,170],"40":["Oklahoma",23460,298],"41":["Oregon",24445,303],"42":["Pennsylvania",25874,144],"44":["Rhode Island",26840,524],"45":["South Carolina",22451,260],"46":["South Dakota",25866,439],"47":["Tennessee",22570,265],"48":["Texas",25227,122],"49":["Utah",25043,402],"50":["Vermont",26323,492],"51":["Virginia",30322,193],"53":["Washington",29109,337],"54":["West Virginia",21494,268],"55":["Wisconsin",26668,179],"56":["Wyoming",26778,725]};

  function check() { console.log("found!")}

  $(function() {
    // initialize
    var map = new Landline.Stateline("#map-container", "states", options);
    // tooltip template
    var tmpl = _.template($("#landline_tooltip_tmpl").html());
    // add tooltips, cache existing style
    map.on("mouseover", function(e, path, data) {
      data.existingStyle = (data.existingStyle || {});
      data.existingStyle["opacity"] = path.attr("opacity");
      data.existingStyle["strokeWidth"] = path.attr("stroke-width");
      path.attr("opacity", 0.5).attr("stroke-width", 1);
    });

    map.on("mousemove", function(e, path, data) {
      $("#tooltip").html(tmpl({
        n: data.get('n'),
        med_income: commaDelimit(census[data.fips][1]),
        moe: census[data.fips][2]
      })).css("left", e.pageX + 20).css("top", e.pageY+20).show();
    });

    map.on("mouseout", function(e, path, data) {
      $("#tooltip").hide();
      _(data.existingStyle).each(function(v, k) {
        path.attr(k, v);
      });
    });

    map.on("click", function(e, path, data) {
      console.log("we got a click!")
    });

    // census data convenience funct
    var incomeColor = function(income) {
      if (income < 23768) return "red";
      if (income < 27329) return "orange";
      if (income < 30891) return "yellow";
      if (income < 34452) return "light-yellow";
      return "blue";
    };

    var commaDelimit = function(a){
      return _.isNumber(a) ? a.toString().replace(/(d)(?=(ddd)+(?!d))/g,"$1,") : "";
    };

    // color by income
    _(census).each(function(ary, fips) {
      map.style(fips, "fill", incomeColor(ary[1]));
    });

    // draw
    map.createMap();
  })


