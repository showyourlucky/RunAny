"""Python 调用 AHK — base64 加密/解密调试脚本

原理：
  Python 通过 COM IDispatch 调用 RunAny 的 huiZz_Text 插件函数
  AHK 插件执行 XOR + Base64 加密/解密，结果通过 COM 返回给 Python

依赖：
  - RunAny 已运行
  - huiZz_Text 插件已加载（RunPlugins/huiZz_Text.ahk）
  - test/runany_client.py（提供 RunAnyCOMClient）
"""

import base64
import sys

from runany_client import RunAnyCOMClient

# huiZz_Text 插件 GUID（来自 RunPlugins/RunAny_ObjReg.ini）
PLUGIN_GUID = "{81AFC7E8-17FF-4760-9E3F-E4736EA38459}"


def ahk_encrypt(ra, text: str, key: str) -> str:
    """调用 AHK 插件加密（XOR + Base64）"""
    return ra.call("runany_encrypt", text, key)


def ahk_decrypt(ra, cipher: str, key: str) -> str:
    """调用 AHK 插件解密（Base64 + XOR）"""
    return ra.call("runany_decrypt", cipher, key)


def py_base64_encode(text: str) -> str:
    """Python 本地 base64 编码（对比用）"""
    return base64.b64encode(text.encode("utf-8")).decode("ascii")


def py_base64_decode(cipher: str) -> str:
    """Python 本地 base64 解码（对比用）"""
    return base64.b64decode(cipher).decode("utf-8")


def main():
    try:
        ra = RunAnyCOMClient(PLUGIN_GUID)
    except ConnectionError as e:
        print(f"连接失败: {e}")
        print("请确保 RunAny 已运行，且 huiZz_Text 插件已加载")
        sys.exit(1)

    # ── 测试 1：AHK 加密/解密可逆性 ──
    print("=" * 50)
    print("测试 1：AHK 加密→解密 可逆性")
    print("=" * 50)

    test_cases = [
        ("Hello World", "mykey"),
        ("你好世界", "密码"),
        ("Python→AHK 通信测试", "key123"),
        ("abc", "xyz"),
    ]

    all_pass = True
    for text, key in test_cases:
        enc = ahk_encrypt(ra, text, key)
        dec = ahk_decrypt(ra, enc, key)
        ok = dec == text
        if not ok:
            all_pass = False
        tag = "✓" if ok else "✗"
        print(f"  {tag} [{key}] {text!r}")
        print(f"    加密: {enc}")
        print(f"    解密: {dec!r}")
    print()

    # ── 测试 2：Python 编码 vs AHK 加密 对比 ──
    print("=" * 50)
    print("测试 2：Python base64 vs AHK XOR+base64 对比")
    print("=" * 50)
    print("  （两者算法不同，此处仅展示差异）")
    print()

    for text, key in [("Hello", "key"), ("Test", "abc")]:
        py_enc = py_base64_encode(text)
        ahk_enc = ahk_encrypt(ra, text, key)
        print(f"  文本: {text!r}, 密钥: {key!r}")
        print(f"    Python base64:     {py_enc}")
        print(f"    AHK XOR+base64:    {ahk_enc}")
        # AHK 解密验证
        ahk_dec = ahk_decrypt(ra, ahk_enc, key)
        print(f"    AHK 解密还原:      {ahk_dec!r}")
        print()

    # ── 测试 3：边界情况 ──
    print("=" * 50)
    print("测试 3：边界情况")
    print("=" * 50)

    edge_cases = [
        ("单字符", "a", "b"),
        ("长文本", "A" * 100, "secret"),
        ("特殊字符", "!@#$%^&*()", "key"),
        ("换行符", "line1\nline2", "key"),
        ("Unicode emoji", "🎉🔒", "key"),
    ]

    for label, text, key in edge_cases:
        try:
            enc = ahk_encrypt(ra, text, key)
            dec = ahk_decrypt(ra, enc, key)
            ok = dec == text
            if not ok:
                all_pass = False
            tag = "✓" if ok else "✗"
            # 截断显示过长的文本
            display = text if len(text) <= 30 else text[:30] + "..."
            print(f"  {tag} {label}: {display!r} → {enc[:40]}...")
        except Exception as e:
            all_pass = False
            print(f"  ✗ {label}: 异常 - {e}")
    print()

    # ── 汇总 ──
    print("=" * 50)
    print(f"结果: {'全部通过 ✓' if all_pass else '存在失败 ✗'}")

    ra.close()


if __name__ == "__main__":
    main()
