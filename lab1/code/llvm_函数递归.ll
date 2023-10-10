define i32 @recursiveFactorial(i32 %n) {
  entry:
    %n.addr = alloca i32
    %result = alloca i32
    store i32 %n, i32* %n.addr
    %0 = load i32, i32* %n.addr
    %1 = icmp sle i32 %0, 1
    br i1 %1, label %if.then, label %if.else

  if.then:
    store i32 1, i32* %result
    br label %return

  if.else:
    %2 = load i32, i32* %n.addr
    %3 = load i32, i32* %n.addr
    %4 = sub i32 %3, 1
    %call = call i32 @recursiveFactorial(i32 %4)
    %5 = mul i32 %2, %call
    store i32 %5, i32* %result
    br label %return

  return:
    %6 = load i32, i32* %result
    ret i32 %6
}

define i32 @main() {
  %call = call i32 @recursiveFactorial(i32 5)
  ret i32 0
}