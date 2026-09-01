-- Test: Apakah Delta+RedFinger bisa exe script tanpa kick?
-- Script ini TIDAK melakukan apa-apa selain menampilkan notifikasi

task.wait(1)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Miles-HUB",
        Text = "Script loaded! No kick = executor works!",
        Duration = 5
    })
end)

print("[Miles-HUB] Test script executed successfully")
