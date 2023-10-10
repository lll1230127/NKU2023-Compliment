define i32 @doubleWhile() {
  %1 = alloca i32
  store i32 5, i32* %1
  %2 = alloca i32
  store i32 7, i32* %2

  ; 进入循环前的标签
  br label %while.cond

while.cond:
  ; 加载 i 的值
  %3 = load i32, i32* %1

  ; 检查循环条件
  %4 = icmp slt i32 %3, 100
  br i1 %4, label %while.body, label %while.end

while.body:
  ; 加载 j 的值
  %5 = load i32, i32* %2

  ; j = j + 1
  %6 = add i32 %5, 1
  store i32 %5, i32* %2

  ; 检查 j < 10
  %7 = icmp slt i32 %6, 10
  br i1 %7, label %while.increment_i, label %while.end

while.increment_i:
  ; i = i + 3
  %8 = load i32, i32* %1
  %9 = add i32 %8, 3
  store i32 %9, i32* %1

  ; 检查 i > 30
  %10 = icmp sgt i32 %9, 30
  br i1 %10, label %while.end, label %while.cond

while.end:
  ret i32 0
}

define i32 @main() {
  %1 = call i32 @doubleWhile()
  ret i32 %1
}
