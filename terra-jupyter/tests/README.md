# terra-jupyter tests

`contract_test.sh` builds nothing: pass it an image. It checks what Leonardo's init and start scripts
and Terra UI expect from the image, starts the server the way Leonardo does, and runs the `pytest`
tests in this folder inside the image.

```
./build_smoke_test_image.sh terra-jupyter
./terra-jupyter/tests/contract_test.sh terra-jupyter:smoke-test
```

On Apple Silicon the amd64 image runs under QEMU, where Jupyter kernels hang. Run
`SKIP_KERNEL_CHECKS=1 ./terra-jupyter/tests/contract_test.sh ...` there; CI runs everything.
