if (is_struct(workbench_ctx) && is_callable(workbench_ctx.refresh_layout)) {
	workbench_ctx.refresh_layout();
}
root.step();


