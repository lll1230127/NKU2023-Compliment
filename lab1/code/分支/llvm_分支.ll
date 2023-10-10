define i32 @ifElseIf() {
entry:
  %a = alloca i32
  store i32 5, i32* %a
  %b = alloca i32
  store i32 10, i32* %b

  ; 测试if else语句
  ; 测试小于等于和大于等于，以及十六进制表示
  %0 = load i32, i32* %a
  %1 = load i32, i32* %b
  %cmp1 = icmp sle i32 %0, 6
  %cmp2 = icmp sge i32 %1, 11
  %or.cond = or i1 %cmp1, %cmp2
  br i1 %or.cond, label %if.then, label %if.else

if.then:
  ; 测试不同位置的return指令
  ; 测试if 语句
  %2 = load i32, i32* %a
  %add = add i32 %2, 10
  %cmp3 = icmp sgt i32 %add, 0
  br i1 %cmp3, label %if.then.if.then, label %if.then.if.else

if.then.if.then:
  ; 返回a+2
  %3 = load i32, i32* %a
  %add1 = add i32 %3, 2
  ret i32 %add1

if.then.if.else:
  ; 返回a+1
  %4 = load i32, i32* %a
  %add2 = add i32 %4, 1
  ret i32 %add2

if.else:
  ; 测试小于等于和大于等于，以及或逻辑和十六进制表示
  %5 = load i32, i32* %a
  %6 = load i32, i32* %b
  %cmp4 = icmp sle i32 %5, 6
  %cmp5 = icmp sge i32 %6, 11
  %or.cond1 = or i1 %cmp4, %cmp5
  br i1 %or.cond1, label %if.else.if.then, label %if.else.if.end

if.else.if.then:
  ; 测试等于和不等于，以及且逻辑
  %7 = load i32, i32* %b
  %cmp6 = icmp eq i32 %7, 10
  %8 = load i32, i32* %a
  %cmp7 = icmp ne i32 %8, 5
  %and.cond = and i1 %cmp6, %cmp7
  br i1 %and.cond, label %if.else.if.then.then, label %if.else.if.else.else

if.else.if.then.then:
  ; a = 25
  store i32 25, i32* %a
  br label %if.else.if.end

if.else.if.else.else:
  ; 测试小于和大于，以及非逻辑
  %9 = load i32, i32* %b
  %10 = load i32, i32* %a
  %cmp8 = icmp sgt i32 %9, 10
  %cmp9 = icmp slt i32 %10, -5
  %not.cond = and i1 %cmp8, %cmp9
  br i1 %not.cond, label %if.else.if.then.else.then, label %if.else.if.end

if.else.if.then.else.then:
  ; a = a + 15
  %11 = load i32, i32* %a
  %add3 = add i32 %11, 15
  store i32 %add3, i32* %a
  br label %if.else.if.end

if.else.if.end:
  %12 = load i32, i32* %a
  ret i32 %12
}

define i32 @main() {
entry:
  %call = call i32 @ifElseIf()
  ret i32 %call
}

declare void @putint(i32)
