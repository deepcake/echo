package data;

class C {
    public var val:String;
    public function new(s = '') {
        this.val = s;
    }
}

abstract AbstractString(String) from String to String {
    public function new(s:String) this = s;
}

abstract AbstractInt(Int) from Int to Int {
    public function new(i:Int) this = i;
}

class C0 {
    public var val:String;
    public function new(s = 'C0') {
        this.val = s;
    }
}

class C1 {
    public var val:String;
    public function new(s = 'C1') {
        this.val = s;
    }
}

class C2 {
    public var val:String;
    public function new(s = 'C2') {
        this.val = s;
    }
}

class C3 {
    public var val:String;
    public function new(s = 'C3') {
        this.val = s;
    }
}
