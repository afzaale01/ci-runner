using System.Collections;
using NUnit.Framework;
using UnityEngine.TestTools;

public class ExamplePlayModeTest
{
    [UnityTest]    public IEnumerator ThisTestAlsoPasses()
    {
        yield return null;
        Assert.IsTrue(true);
    }
}
