{
  lib,
  config,
  stdenv,
  blas,
  lapack,
  buildPythonPackage,
  fetchurl,
  cudaSupport ? config.cudaSupport,

  # build-system
  setuptools,

  # dependencies
  jaxlib,
  ml-dtypes,
  numpy,
  opt-einsum,
  scipy,

  # optional-dependencies
  jax-cuda12-plugin,

  # tests
  cloudpickle,
  hypothesis,
  matplotlib,
  pytestCheckHook,
  pytest-xdist,

  # passthru
  callPackage,
  jax,
  jaxlib-build,
  jaxlib-bin,
}:

let
  usingMKL = blas.implementation == "mkl" || lapack.implementation == "mkl";
in
buildPythonPackage rec {
  pname = "jax";
  version = "0.6.0";
  format = "wheel";

  src = fetchurl {
    url = "https://files.pythonhosted.org/packages/31/25/32c5e2c919da4faaea9ef5088437ab6e01738c49402e4ec8a6c7b49e30ef/jax-0.6.0-py3-none-any.whl";
    # hash = "sha256-5+Mvm+Ua5cxoVCJZWMV96MyiGH0nmEQzhGWxXoof5/I=";  # 7.2
    hash = "sha256-IrIYJ1l8bWtG6IVDtPw3L83fHMEkdmBFLeAgzEvaGvw=";
    # hash = lib.fakeHash;  # You'll need to update this hash
  };

  dependencies = [
    jaxlib
    ml-dtypes
    numpy
    opt-einsum
    scipy
  ]
  ++ lib.optionals cudaSupport optional-dependencies.cuda;

  optional-dependencies = rec {
    cuda = [ jax-cuda12-plugin ];
    cuda12 = cuda;
    cuda12_pip = cuda;
    cuda12_local = cuda;
  };

  nativeCheckInputs = [
    cloudpickle
    hypothesis
    matplotlib
    pytestCheckHook
    pytest-xdist
  ];

  doCheck = false;

  # high parallelism will result in the tests getting stuck
  # dontUsePytestXdist = true;

  # pytestFlags = [
  #   "--numprocesses=4"
  #   "-Wignore::DeprecationWarning"
  # ];

  # # NOTE: Don't run the tests in the experimental directory as they require flax
  # # which creates a circular dependency. See https://discourse.nixos.org/t/how-to-nix-ify-python-packages-with-circular-dependencies/14648/2.
  # # Not a big deal, this is how the JAX docs suggest running the test suite
  # # anyhow.
  # enabledTestPaths = [
  #   "tests/"
  # ];

  # disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
  #   # SystemError: nanobind::detail::nb_func_error_except(): exception could not be translated!
  #   # reported at: https://github.com/jax-ml/jax/issues/26106
  #   "tests/pjit_test.py::PJitErrorTest::testAxisResourcesMismatch"
  #   "tests/shape_poly_test.py::ShapePolyTest"
  #   "tests/tree_util_test.py::TreeTest"

  #   # Mostly AssertionError on numerical tests failing since 0.7.0
  #   # https://github.com/jax-ml/jax/issues/31428
  #   "tests/export_back_compat_test.py"
  #   "tests/lax_numpy_test.py"
  #   "tests/lax_scipy_test.py"
  #   "tests/lax_test.py"
  #   "tests/linalg_test.py"
  # ];

  # # Prevents `tests/export_back_compat_test.py::CompatTest::test_*` tests from failing on darwin with
  # # PermissionError: [Errno 13] Permission denied: '/tmp/back_compat_testdata/test_*.py'
  # # See https://github.com/google/jax/blob/jaxlib-v0.4.27/jax/_src/internal_test_util/export_back_compat_test_util.py#L240-L241
  # # NOTE: this doesn't seem to be an issue on linux
  # preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
  #   export TEST_UNDECLARED_OUTPUTS_DIR=$(mktemp -d)
  # '';

  # disabledTests = [
  #   # Exceeds tolerance when the machine is busy
  #   "test_custom_linear_solve_aux"
  # ]
  # ++ lib.optionals usingMKL [
  #   # See
  #   #  * https://github.com/google/jax/issues/9705
  #   #  * https://discourse.nixos.org/t/getting-different-results-for-the-same-build-on-two-equally-configured-machines/17921
  #   #  * https://github.com/NixOS/nixpkgs/issues/161960
  #   "test_custom_linear_solve_cholesky"
  #   "test_custom_root_with_aux"
  #   "testEigvalsGrad_shape"
  # ]
  # ++ lib.optionals stdenv.hostPlatform.isAarch64 [
  #   # Fails on some hardware due to some numerical error
  #   # See https://github.com/google/jax/issues/18535
  #   "testQdwhWithOnRankDeficientInput5"
  # ]
  # ++ lib.optionals stdenv.hostPlatform.isDarwin [
  #   # SystemError: nanobind::detail::nb_func_error_except(): exception could not be translated!
  #   # reported at: https://github.com/jax-ml/jax/issues/26106
  #   "testInAxesPyTreePrefixMismatchError"
  #   "testInAxesPyTreePrefixMismatchErrorKwargs"
  #   "testOutAxesPyTreePrefixMismatchError"
  #   "test_tree_map"
  #   "test_tree_prefix_error"
  #   "test_vjp_rule_inconsistent_pytree_structures_error"
  #   "test_vmap_in_axes_tree_prefix_error"
  #   "test_vmap_mismatched_axis_sizes_error_message_issue_705"
  # ];

  pythonImportsCheck = [ "jax" ];

  # Test CUDA-enabled jax and jaxlib. Running CUDA-enabled tests is not
  # currently feasible within the nix build environment so we have to maintain
  # this script separately. See https://github.com/NixOS/nixpkgs/pull/256230
  # for a possible remedy to this situation.
  #
  # Run these tests with eg
  #
  #   NIXPKGS_ALLOW_UNFREE=1 nixglhost -- nix run --impure .#python3Packages.jax.passthru.tests.test_cuda_jaxlibBin
  passthru.tests = {
    # jaxlib-build is broken as of 2024-12-20
    # test_cuda_jaxlibSource = callPackage ./test-cuda.nix {
    #   jax = jax.override { jaxlib = jaxlib-build; };
    # };
    test_cuda_jaxlibBin = callPackage ./test-cuda.nix {
      jax = jax.override { jaxlib = jaxlib-bin; };
    };
  };

  # updater fails to pick the correct branch
  passthru.skipBulkUpdate = true;

  meta = {
    description = "JAX frontend (pre-built wheel): differentiate, compile, and transform Numpy code";
    homepage = "https://github.com/google/jax";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      GaetanLepage
      samuela
    ];
  };
}