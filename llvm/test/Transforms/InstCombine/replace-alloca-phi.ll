; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=instcombine -S -o - %s | FileCheck %s

target datalayout="p5:32:32-A5"

@g1 = constant [32 x i8] zeroinitializer
@g2 = addrspace(1) constant [32 x i8] zeroinitializer

define i8 @remove_alloca_use_arg(i1 %cond) {
; CHECK-LABEL: @remove_alloca_use_arg(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF:%.*]], label [[ELSE:%.*]]
; CHECK:       if:
; CHECK-NEXT:    br label [[SINK:%.*]]
; CHECK:       else:
; CHECK-NEXT:    br label [[SINK]]
; CHECK:       sink:
; CHECK-NEXT:    [[PTR1:%.*]] = phi ptr [ getelementptr inbounds ([32 x i8], ptr @g1, i64 0, i64 2), [[IF]] ], [ getelementptr inbounds ([32 x i8], ptr @g1, i64 0, i64 1), [[ELSE]] ]
; CHECK-NEXT:    [[LOAD:%.*]] = load i8, ptr [[PTR1]], align 1
; CHECK-NEXT:    ret i8 [[LOAD]]
;
entry:
  %alloca = alloca [32 x i8], align 4, addrspace(1)
  call void @llvm.memcpy.p1.p0.i64(ptr addrspace(1) %alloca, ptr @g1, i64 256, i1 false)
  br i1 %cond, label %if, label %else

if:
  %val.if = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 2
  br label %sink

else:
  %val.else = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 1
  br label %sink

sink:
  %ptr = phi ptr addrspace(1) [ %val.if, %if ], [ %val.else, %else ]
  %load = load i8, ptr addrspace(1) %ptr
  ret i8 %load
}

define i8 @volatile_load_keep_alloca(i1 %cond) {
; CHECK-LABEL: @volatile_load_keep_alloca(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca [32 x i8], align 4, addrspace(1)
; CHECK-NEXT:    call void @llvm.memcpy.p1.p0.i64(ptr addrspace(1) noundef align 4 dereferenceable(256) [[ALLOCA]], ptr noundef nonnull align 16 dereferenceable(256) @g1, i64 256, i1 false)
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF:%.*]], label [[ELSE:%.*]]
; CHECK:       if:
; CHECK-NEXT:    [[VAL_IF:%.*]] = getelementptr inbounds [32 x i8], ptr addrspace(1) [[ALLOCA]], i64 0, i64 1
; CHECK-NEXT:    br label [[SINK:%.*]]
; CHECK:       else:
; CHECK-NEXT:    [[VAL_ELSE:%.*]] = getelementptr inbounds [32 x i8], ptr addrspace(1) [[ALLOCA]], i64 0, i64 2
; CHECK-NEXT:    br label [[SINK]]
; CHECK:       sink:
; CHECK-NEXT:    [[PTR:%.*]] = phi ptr addrspace(1) [ [[VAL_IF]], [[IF]] ], [ [[VAL_ELSE]], [[ELSE]] ]
; CHECK-NEXT:    [[LOAD:%.*]] = load volatile i8, ptr addrspace(1) [[PTR]], align 1
; CHECK-NEXT:    ret i8 [[LOAD]]
;
entry:
  %alloca = alloca [32 x i8], align 4, addrspace(1)
  call void @llvm.memcpy.p1.p0.i64(ptr addrspace(1) %alloca, ptr @g1, i64 256, i1 false)
  br i1 %cond, label %if, label %else

if:
  %val.if = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 1
  br label %sink

else:
  %val.else = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 2
  br label %sink

sink:
  %ptr = phi ptr addrspace(1) [ %val.if, %if ], [ %val.else, %else ]
  %load = load volatile i8, ptr addrspace(1) %ptr
  ret i8 %load
}


define i8 @no_memcpy_keep_alloca(i1 %cond) {
; CHECK-LABEL: @no_memcpy_keep_alloca(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca [32 x i8], align 4, addrspace(1)
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF:%.*]], label [[ELSE:%.*]]
; CHECK:       if:
; CHECK-NEXT:    [[VAL_IF:%.*]] = getelementptr inbounds [32 x i8], ptr addrspace(1) [[ALLOCA]], i64 0, i64 1
; CHECK-NEXT:    br label [[SINK:%.*]]
; CHECK:       else:
; CHECK-NEXT:    [[VAL_ELSE:%.*]] = getelementptr inbounds [32 x i8], ptr addrspace(1) [[ALLOCA]], i64 0, i64 2
; CHECK-NEXT:    br label [[SINK]]
; CHECK:       sink:
; CHECK-NEXT:    [[PTR:%.*]] = phi ptr addrspace(1) [ [[VAL_IF]], [[IF]] ], [ [[VAL_ELSE]], [[ELSE]] ]
; CHECK-NEXT:    [[LOAD:%.*]] = load volatile i8, ptr addrspace(1) [[PTR]], align 1
; CHECK-NEXT:    ret i8 [[LOAD]]
;
entry:
  %alloca = alloca [32 x i8], align 4, addrspace(1)
  br i1 %cond, label %if, label %else

if:
  %val.if = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 1
  br label %sink

else:
  %val.else = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 2
  br label %sink

sink:
  %ptr = phi ptr addrspace(1) [ %val.if, %if ], [ %val.else, %else ]
  %load = load volatile i8, ptr addrspace(1) %ptr
  ret i8 %load
}

define i8 @loop_phi_remove_alloca(i1 %cond) {
; CHECK-LABEL: @loop_phi_remove_alloca(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB_0:%.*]]
; CHECK:       bb.0:
; CHECK-NEXT:    [[PTR1:%.*]] = phi ptr [ getelementptr inbounds ([32 x i8], ptr @g1, i64 0, i64 1), [[ENTRY:%.*]] ], [ getelementptr inbounds ([32 x i8], ptr @g1, i64 0, i64 2), [[BB_1:%.*]] ]
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[BB_1]], label [[EXIT:%.*]]
; CHECK:       bb.1:
; CHECK-NEXT:    br label [[BB_0]]
; CHECK:       exit:
; CHECK-NEXT:    [[LOAD:%.*]] = load i8, ptr [[PTR1]], align 1
; CHECK-NEXT:    ret i8 [[LOAD]]
;
entry:
  %alloca = alloca [32 x i8], align 4, addrspace(1)
  call void @llvm.memcpy.p1.p0.i64(ptr addrspace(1) %alloca, ptr @g1, i64 256, i1 false)
  %val1 = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 1
  br label %bb.0

bb.0:
  %ptr = phi ptr addrspace(1) [ %val1, %entry ], [ %val2, %bb.1 ]
  br i1 %cond, label %bb.1, label %exit

bb.1:
  %val2 = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 2
  br label %bb.0

exit:
  %load = load i8, ptr addrspace(1) %ptr
  ret i8 %load
}

define i32 @remove_alloca_ptr_arg(i1 %c, ptr %ptr) {
; CHECK-LABEL: @remove_alloca_ptr_arg(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[IF:%.*]], label [[JOIN:%.*]]
; CHECK:       if:
; CHECK-NEXT:    br label [[JOIN]]
; CHECK:       join:
; CHECK-NEXT:    [[PHI:%.*]] = phi ptr [ @g1, [[IF]] ], [ [[PTR:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr [[PHI]], align 4
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %alloca = alloca [32 x i8]
  call void @llvm.memcpy.p0.p0.i64(ptr %alloca, ptr @g1, i64 32, i1 false)
  br i1 %c, label %if, label %join

if:
  br label %join

join:
  %phi = phi ptr [ %alloca, %if ], [ %ptr, %entry ]
  %v = load i32, ptr %phi
  ret i32 %v
}

define i8 @loop_phi_late_memtransfer_remove_alloca(i1 %cond) {
; CHECK-LABEL: @loop_phi_late_memtransfer_remove_alloca(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB_0:%.*]]
; CHECK:       bb.0:
; CHECK-NEXT:    [[PTR1:%.*]] = phi ptr [ getelementptr inbounds ([32 x i8], ptr @g1, i64 0, i64 1), [[ENTRY:%.*]] ], [ getelementptr inbounds ([32 x i8], ptr @g1, i64 0, i64 2), [[BB_1:%.*]] ]
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[BB_1]], label [[EXIT:%.*]]
; CHECK:       bb.1:
; CHECK-NEXT:    br label [[BB_0]]
; CHECK:       exit:
; CHECK-NEXT:    [[LOAD:%.*]] = load i8, ptr [[PTR1]], align 1
; CHECK-NEXT:    ret i8 [[LOAD]]
;
entry:
  %alloca = alloca [32 x i8], align 4, addrspace(1)
  %val1 = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 1
  br label %bb.0

bb.0:
  %ptr = phi ptr addrspace(1) [ %val1, %entry ], [ %val2, %bb.1 ]
  br i1 %cond, label %bb.1, label %exit

bb.1:
  %val2 = getelementptr inbounds [32 x i8], ptr addrspace(1) %alloca, i32 0, i32 2
  call void @llvm.memcpy.p1.p0.i64(ptr addrspace(1) %alloca, ptr @g1, i64 256, i1 false)
  br label %bb.0

exit:
  %load = load i8, ptr addrspace(1) %ptr
  ret i8 %load
}

define i32 @test_memcpy_after_phi(i1 %cond, ptr %ptr) {
; CHECK-LABEL: @test_memcpy_after_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca [32 x i8], align 1
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF:%.*]], label [[JOIN:%.*]]
; CHECK:       if:
; CHECK-NEXT:    br label [[JOIN]]
; CHECK:       join:
; CHECK-NEXT:    [[PHI:%.*]] = phi ptr [ [[A]], [[IF]] ], [ [[PTR:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    call void @llvm.memcpy.p0.p0.i64(ptr noundef nonnull align 1 dereferenceable(32) [[PHI]], ptr noundef nonnull align 16 dereferenceable(32) @g1, i64 32, i1 false)
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr [[PHI]], align 4
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %a = alloca [32 x i8]
  br i1 %cond, label %if, label %join

if:
  br label %join

join:
  %phi = phi ptr [ %a, %if ], [ %ptr, %entry ]
  call void @llvm.memcpy.p0.p0.i64(ptr %phi, ptr @g1, i64 32, i1 false)
  %v = load i32, ptr %phi
  ret i32 %v
}

define i32 @addrspace_diff_keep_alloca(i1 %cond, ptr %x) {
; CHECK-LABEL: @addrspace_diff_keep_alloca(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca [32 x i8], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0.p1.i64(ptr noundef nonnull align 1 dereferenceable(32) [[A]], ptr addrspace(1) noundef align 16 dereferenceable(32) @g2, i64 32, i1 false)
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF:%.*]], label [[JOIN:%.*]]
; CHECK:       if:
; CHECK-NEXT:    br label [[JOIN]]
; CHECK:       join:
; CHECK-NEXT:    [[PHI:%.*]] = phi ptr [ [[A]], [[IF]] ], [ [[X:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr [[PHI]], align 4
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %a = alloca [32 x i8]
  call void @llvm.memcpy.p0.p1.i64(ptr %a, ptr addrspace(1) @g2, i64 32, i1 false)
  br i1 %cond, label %if, label %join

if:
  br label %join

join:
  %phi = phi ptr [ %a, %if ], [ %x, %entry ]
  %v = load i32, ptr %phi
  ret i32 %v
}

define i32 @addrspace_diff_keep_alloca_extra_gep(i1 %cond, ptr %x) {
; CHECK-LABEL: @addrspace_diff_keep_alloca_extra_gep(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca [32 x i8], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0.p1.i64(ptr noundef nonnull align 1 dereferenceable(32) [[A]], ptr addrspace(1) noundef align 16 dereferenceable(32) @g2, i64 32, i1 false)
; CHECK-NEXT:    br i1 [[COND:%.*]], label [[IF:%.*]], label [[JOIN:%.*]]
; CHECK:       if:
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr inbounds i8, ptr [[A]], i64 4
; CHECK-NEXT:    br label [[JOIN]]
; CHECK:       join:
; CHECK-NEXT:    [[PHI:%.*]] = phi ptr [ [[GEP]], [[IF]] ], [ [[X:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr [[PHI]], align 4
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %a = alloca [32 x i8]
  call void @llvm.memcpy.p0.p1.i64(ptr %a, ptr addrspace(1) @g2, i64 32, i1 false)
  %gep = getelementptr i8, ptr %a, i64 4
  br i1 %cond, label %if, label %join

if:
  br label %join

join:
  %phi = phi ptr [ %gep, %if ], [ %x, %entry ]
  %v = load i32, ptr %phi
  ret i32 %v
}

define i32 @phi_loop(i1 %c) {
; CHECK-LABEL: @phi_loop(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[PTR:%.*]] = phi ptr [ @g1, [[ENTRY:%.*]] ], [ [[PTR_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[PTR_NEXT]] = getelementptr i8, ptr [[PTR]], i64 4
; CHECK-NEXT:    br i1 [[C:%.*]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr [[PTR]], align 4
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %alloca = alloca [32 x i8]
  call void @llvm.memcpy.p0.p0.i64(ptr %alloca, ptr @g1, i64 32, i1 false)
  br label %loop

loop:
  %ptr = phi ptr [ %alloca, %entry ], [ %ptr.next, %loop ]
  %ptr.next = getelementptr i8, ptr %ptr, i64 4
  br i1 %c, label %exit, label %loop

exit:
  %v = load i32, ptr %ptr
  ret i32 %v
}

define i32 @phi_loop_different_addrspace(i1 %c) {
; CHECK-LABEL: @phi_loop_different_addrspace(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca [32 x i8], align 1
; CHECK-NEXT:    call void @llvm.memcpy.p0.p1.i64(ptr noundef nonnull align 1 dereferenceable(32) [[ALLOCA]], ptr addrspace(1) noundef align 16 dereferenceable(32) @g2, i64 32, i1 false)
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[PTR:%.*]] = phi ptr [ [[ALLOCA]], [[ENTRY:%.*]] ], [ [[PTR_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[PTR_NEXT]] = getelementptr i8, ptr [[PTR]], i64 4
; CHECK-NEXT:    br i1 [[C:%.*]], label [[EXIT:%.*]], label [[LOOP]]
; CHECK:       exit:
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr [[PTR]], align 4
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %alloca = alloca [32 x i8]
  call void @llvm.memcpy.p0.p1.i64(ptr %alloca, ptr addrspace(1) @g2, i64 32, i1 false)
  br label %loop

loop:
  %ptr = phi ptr [ %alloca, %entry ], [ %ptr.next, %loop ]
  %ptr.next = getelementptr i8, ptr %ptr, i64 4
  br i1 %c, label %exit, label %loop

exit:
  %v = load i32, ptr %ptr
  ret i32 %v
}

declare void @llvm.memcpy.p1.p0.i64(ptr addrspace(1), ptr, i64, i1)
declare void @llvm.memcpy.p0.p0.i64(ptr, ptr, i64, i1)
declare void @llvm.memcpy.p0.p1.i64(ptr, ptr addrspace(1), i64, i1)
