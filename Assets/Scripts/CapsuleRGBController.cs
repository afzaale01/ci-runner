using UnityEngine;

{
    [SerializeField]

    [SerializeField]


    {
        capsuleMaterial = capsule.material;
        hue = 0f;
    }

    {
        hue += Time.deltaTime * speed;
        if (hue > 1f)
            hue -= 1f;

        Color rgbColor = Color.HSVToRGB(hue, 1f, 1f);
        capsuleMaterial.color = rgbColor;
    }
}
