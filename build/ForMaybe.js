Elm.ForMaybe = Elm.ForMaybe || {};
Elm.ForMaybe.make = function (_elm) {
   "use strict";
   _elm.ForMaybe = _elm.ForMaybe || {};
   if (_elm.ForMaybe.values)
   return _elm.ForMaybe.values;
   var _op = {},
   _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "ForMaybe",
   $Basics = Elm.Basics.make(_elm),
   $List = Elm.List.make(_elm),
   $Maybe = Elm.Maybe.make(_elm);
   _op["??>"] = F2(function (mx,
   mf) {
      return $Maybe.isJust(mx) && $Maybe.isJust(mf) ? $Maybe.Just(A2(F2(function (_v0,
      _v1) {
         return function () {
            switch (_v1.ctor)
            {case "Just":
               return function () {
                    switch (_v0.ctor)
                    {case "Just":
                       return _v0._0(_v1._0);}
                    _E.Case($moduleName,
                    "on line 33, column 51 to 54");
                 }();}
            _E.Case($moduleName,
            "on line 33, column 51 to 54");
         }();
      }),
      mf,
      mx)) : $Maybe.Nothing;
   });
   _op["<??"] = F2(function (mf,
   mx) {
      return $Maybe.isJust(mx) && $Maybe.isJust(mf) ? $Maybe.Just(A2(F2(function (_v6,
      _v7) {
         return function () {
            switch (_v7.ctor)
            {case "Just":
               return function () {
                    switch (_v6.ctor)
                    {case "Just":
                       return _v6._0(_v7._0);}
                    _E.Case($moduleName,
                    "on line 30, column 51 to 54");
                 }();}
            _E.Case($moduleName,
            "on line 30, column 51 to 54");
         }();
      }),
      mf,
      mx)) : $Maybe.Nothing;
   });
   _op["?>"] = F2(function (mx,f) {
      return function () {
         switch (mx.ctor)
         {case "Just":
            return $Maybe.Just(f(mx._0));
            case "Nothing":
            return $Maybe.Nothing;}
         _E.Case($moduleName,
         "between lines 22 and 24");
      }();
   });
   _op["<?"] = F2(function (f,mx) {
      return function () {
         switch (mx.ctor)
         {case "Just":
            return $Maybe.Just(f(mx._0));
            case "Nothing":
            return $Maybe.Nothing;}
         _E.Case($moduleName,
         "between lines 19 and 21");
      }();
   });
   _op["$$>"] = F2(function (lx,
   lf) {
      return A3($List.zipWith,
      F2(function (f,x) {
         return f(x);
      }),
      lf,
      lx);
   });
   _op["<$$"] = F2(function (lf,
   lx) {
      return A3($List.zipWith,
      F2(function (f,x) {
         return f(x);
      }),
      lf,
      lx);
   });
   _op["$>"] = F2(function (lx,f) {
      return A2($List.map,f,lx);
   });
   _op["<$"] = F2(function (f,lx) {
      return A2($List.map,f,lx);
   });
   _elm.ForMaybe.values = {_op: _op};
   return _elm.ForMaybe.values;
};