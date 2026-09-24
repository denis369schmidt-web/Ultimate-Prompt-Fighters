#include "PFUCharacterAssembler.h"

#include "Components/StaticMeshComponent.h"
#include "Materials/MaterialInstanceDynamic.h"
#include "GameFramework/Actor.h"

UStaticMeshComponent* UPFUCharacterAssembler::AddModule(FName Name, const TCHAR* MeshPath, FVector Location, FVector Scale, FLinearColor Color)
{
    AActor* Owner = GetOwner();
    UStaticMesh* Mesh = LoadObject<UStaticMesh>(nullptr, MeshPath);
    if (!Owner || !Mesh) return nullptr;
    UStaticMeshComponent* Module = NewObject<UStaticMeshComponent>(Owner, Name);
    Module->SetStaticMesh(Mesh);
    Module->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    Module->SetupAttachment(Owner->GetRootComponent());
    Module->SetRelativeLocation(Location);
    Module->SetRelativeScale3D(Scale);
    Module->RegisterComponent();
    if (UMaterialInterface* BaseMaterial = Module->GetMaterial(0))
    {
        UMaterialInstanceDynamic* Dynamic = UMaterialInstanceDynamic::Create(BaseMaterial, Module);
        Dynamic->SetVectorParameterValue(TEXT("Color"), Color);
        Module->SetMaterial(0, Dynamic);
    }
    Modules.Add(Module);
    return Module;
}

void UPFUCharacterAssembler::AssembleFallback(const FPFUFighterProfile& Profile)
{
    for (UStaticMeshComponent* Module : Modules) if (Module) Module->DestroyComponent();
    Modules.Reset();
    const bool bHeavy = Profile.Archetype == EPFUArchetype::Guardian || Profile.Archetype == EPFUArchetype::Bruiser;
    const FVector BodyScale = bHeavy ? FVector(0.75f, 0.55f, 1.0f) : FVector(0.52f, 0.42f, 0.82f);
    AddModule(TEXT("PFU_Body"), TEXT("/Engine/BasicShapes/Sphere.Sphere"), FVector(0, 0, 35), BodyScale, Profile.PrimaryColor);
    AddModule(TEXT("PFU_Head"), TEXT("/Engine/BasicShapes/Sphere.Sphere"), FVector(0, 0, bHeavy ? 105 : 92), bHeavy ? FVector(0.38f) : FVector(0.28f), Profile.PrimaryColor);
    AddModule(TEXT("PFU_Accent"), TEXT("/Engine/BasicShapes/Cube.Cube"), FVector(0, -28, bHeavy ? 55 : 48), bHeavy ? FVector(0.5f, 0.08f, 0.12f) : FVector(0.32f, 0.05f, 0.08f), Profile.AccentColor);
    const float Side = bHeavy ? 58.0f : 44.0f;
    for (int32 Sign : { -1, 1 })
    {
        AddModule(*FString::Printf(TEXT("PFU_Arm_%d"), Sign), TEXT("/Engine/BasicShapes/Cylinder.Cylinder"), FVector(Sign * Side, 0, 52), bHeavy ? FVector(0.26f, 0.26f, 0.75f) : FVector(0.16f, 0.16f, 0.62f), Profile.PrimaryColor);
        AddModule(*FString::Printf(TEXT("PFU_Weapon_%d"), Sign), TEXT("/Engine/BasicShapes/Cube.Cube"), FVector(Sign * (Side + 12), -5, 10), bHeavy ? FVector(0.34f) : FVector(0.07f, 0.13f, 0.55f), Profile.AccentColor);
    }
}

